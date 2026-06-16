import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/audio/audio_capture_service.dart';
import 'package:medicail/core/config/app_config.dart';
import 'package:medicail/core/error/failure.dart';
import 'package:medicail/core/network/auth_token_storage.dart';
import 'package:medicail/core/utils/anonymization_helper.dart';
import 'package:medicail/features/recording/domain/entities/note_processing_result.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';
import 'package:medicail/features/recording/domain/repositories/note_processing_repository.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_event.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_state.dart';

@injectable
class VoiceCaptureBloc extends Bloc<VoiceCaptureEvent, VoiceCaptureState> {
  VoiceCaptureBloc(
    this._audioCaptureService,
    this._recordingSessionRepository,
    this._noteProcessingRepository,
    this._tokenStorage,
  ) : super(const VoiceCaptureInitial()) {
    on<VoiceCaptureInitializeRequested>(_onInitialize);
    on<VoiceCaptureStartRecording>(_onStartRecording);
    on<VoiceCaptureStopRecording>(_onStopRecording);
    on<VoiceCaptureFinishConsultation>(_onFinishConsultation);
    on<VoiceCaptureClearTranscript>(_onClearTranscript);
    on<VoiceCaptureListeningSessionEnded>(_onListeningSessionEnded);
    on<VoiceCaptureTranscriptUpdated>(_onTranscriptUpdated);
  }

  final AudioCaptureService _audioCaptureService;
  final RecordingSessionRepository _recordingSessionRepository;
  final NoteProcessingRepository _noteProcessingRepository;
  final AuthTokenStorage _tokenStorage;
  String _segmentBase = '';
  RecordingSession? _activeSession;

  Future<void> _onInitialize(
    VoiceCaptureInitializeRequested event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    emit(const VoiceCaptureReady());
  }

  Future<void> _onStartRecording(
    VoiceCaptureStartRecording event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    final currentTranscript = _currentTranscript;
    _segmentBase = currentTranscript;
    try {
      await _audioCaptureService.initialize();
      await _ensureActiveSessionStarted(
        currentTranscript,
        patientId: event.patientId,
      );
      await _startListeningSession();
      emit(RecordingInProgress(transcript: currentTranscript));
    } catch (error) {
      await _failActiveSession(currentTranscript);
      emit(
        VoiceCaptureFailure(
          Failure.fromException(error).message,
          transcript: currentTranscript,
        ),
      );
    }
  }

  Future<void> _onStopRecording(
    VoiceCaptureStopRecording event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    try {
      await _audioCaptureService.stopListening();
      await _saveActiveSessionTranscript(_currentTranscript);
      _segmentBase = '';
      emit(ListeningPaused(transcript: _currentTranscript));
    } catch (error) {
      await _failActiveSession(_currentTranscript);
      emit(
        VoiceCaptureFailure(
          Failure.fromException(error).message,
          transcript: _currentTranscript,
        ),
      );
    }
  }

  Future<void> _onFinishConsultation(
    VoiceCaptureFinishConsultation event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    final transcript = _currentTranscript;
    final sessionId = _activeSession?.id ?? '';
    try {
      await _audioCaptureService.stopListening();
      emit(VoiceCaptureProcessing(transcript: transcript));
      await _completeActiveSession(
        sessionId: sessionId,
        transcript: transcript,
      );
      _segmentBase = '';
      emit(VoiceCaptureConsultationFinished(
        sessionId: sessionId,
        transcript: transcript,
      ));
    } catch (error) {
      await _failActiveSession(transcript);
      emit(
        VoiceCaptureFailure(
          Failure.fromException(error).message,
          transcript: transcript,
        ),
      );
    }
  }

  void _onClearTranscript(
    VoiceCaptureClearTranscript event,
    Emitter<VoiceCaptureState> emit,
  ) {
    if (state is RecordingInProgress) {
      return;
    }
    _segmentBase = '';
    _activeSession = null;
    emit(const VoiceCaptureReady());
  }

  Future<void> _onListeningSessionEnded(
    VoiceCaptureListeningSessionEnded event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    if (state is! RecordingInProgress) {
      return;
    }

    final transcript = _currentTranscript;
    _segmentBase = transcript;
    try {
      await _startListeningSession();
      emit(RecordingInProgress(transcript: transcript));
    } catch (error) {
      await _failActiveSession(transcript);
      emit(
        VoiceCaptureFailure(
          Failure.fromException(error).message,
          transcript: transcript,
        ),
      );
    }
  }

  Future<void> _onTranscriptUpdated(
    VoiceCaptureTranscriptUpdated event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    if (state is! RecordingInProgress) {
      return;
    }

    final anonymized = AnonymizationHelper.anonymize(event.rawText);
    if (anonymized.isEmpty) {
      return;
    }

    final merged = _mergeTranscript(_segmentBase, anonymized);
    await _saveActiveSessionTranscript(merged);
    emit(RecordingInProgress(transcript: merged));
  }

  Future<void> _startListeningSession() {
    return _audioCaptureService.startListening(
      onResult: (text) {
        if (isClosed) return;
        add(VoiceCaptureTranscriptUpdated(text));
      },
      onListeningEnded: () {
        if (isClosed) return;
        add(const VoiceCaptureListeningSessionEnded());
      },
    );
  }

  String _mergeTranscript(String base, String segment) {
    if (base.isEmpty) {
      return segment;
    }
    if (segment.isEmpty) {
      return base;
    }
    if (segment.startsWith(base)) {
      return segment;
    }
    return '$base $segment';
  }

  String get _currentTranscript {
    return switch (state) {
      VoiceCaptureReady(:final transcript) => transcript,
      RecordingInProgress(:final transcript) => transcript,
      ListeningPaused(:final transcript) => transcript,
      VoiceCaptureProcessing(:final transcript) => transcript,
      VoiceCaptureFailure(:final transcript) => transcript,
      _ => '',
    };
  }

  String _generateSessionId(DateTime startedAt) {
    return 'recording_${startedAt.toUtc().microsecondsSinceEpoch}';
  }

  Future<void> _ensureActiveSessionStarted(
    String transcript, {
    String? patientId,
  }) async {
    final existingSession = _activeSession;
    if (existingSession != null &&
        existingSession.status == RecordingSessionStatus.recording) {
      final updated = existingSession.copyWith(transcript: transcript);
      _activeSession = updated;
      await _recordingSessionRepository.save(updated);
      return;
    }

    final startedAt = DateTime.now();
    final session = RecordingSession(
      id: _generateSessionId(startedAt),
      patientId: patientId,
      startedAt: startedAt,
      transcript: transcript,
      status: RecordingSessionStatus.recording,
    );
    _activeSession = session;
    await _recordingSessionRepository.save(_activeSession!);
  }

  Future<void> _completeActiveSession({
    required String sessionId,
    required String transcript,
  }) async {
    final session = _activeSession;
    if (session == null) {
      return;
    }

    final processedSoapNote = await _processTranscript(
      sessionId: sessionId,
      transcript: transcript,
    );

    final completed = session.copyWith(
      endedAt: DateTime.now(),
      transcript: transcript,
      soapNote: processedSoapNote,
      status: RecordingSessionStatus.completed,
    );
    _activeSession = completed;
    await _recordingSessionRepository.save(completed);
  }

  Future<void> _failActiveSession(String transcript) async {
    final session = _activeSession;
    if (session == null) {
      return;
    }

    final failed = session.copyWith(
      endedAt: DateTime.now(),
      transcript: transcript,
      status: RecordingSessionStatus.failed,
    );
    _activeSession = failed;
    await _recordingSessionRepository.save(failed);
  }

  Future<void> _saveActiveSessionTranscript(String transcript) async {
    final session = _activeSession;
    if (session == null) {
      return;
    }

    final updated = session.copyWith(transcript: transcript);
    _activeSession = updated;
    await _recordingSessionRepository.save(updated);
  }

  SoapNote _generateMockSoapNote(String transcript) {
    final cleanTranscript = transcript.trim();
    return SoapNote(
      subjective: cleanTranscript.isEmpty
          ? '- Motif de consultation :\n- Symptômes décrits :'
          : cleanTranscript,
      objective: '- Constantes :\n- Examen clinique :',
      assessment: '- Diagnostics suspectés :',
      plan: '- Traitement :\n- Examens complémentaires :\n- Suivi :',
    );
  }

  Future<SoapNote> _processTranscript({
    required String sessionId,
    required String transcript,
  }) async {
    final cleanTranscript = transcript.trim();
    if (cleanTranscript.isEmpty) {
      return _generateMockSoapNote(cleanTranscript);
    }

    final token = await _tokenStorage.readToken();
    if (token == AppConfig.mockAdminToken) {
      return _generateMockSoapNote(cleanTranscript);
    }

    final result = await _noteProcessingRepository.processNote(
      sessionId: sessionId,
      rawText: cleanTranscript,
    );
    final sessionSummary = await _noteProcessingRepository.summarizeNote(
      sessionId: sessionId,
      anonymizedText: result.anonymizedText,
    );

    if (result.aiResponse.isEmpty && sessionSummary.trim().isEmpty) {
      return _generateMockSoapNote(result.anonymizedText);
    }

    return _soapNoteFromProcessingResult(
      result,
      sessionSummary: sessionSummary,
    );
  }

  SoapNote _soapNoteFromProcessingResult(
    NoteProcessingResult result, {
    String sessionSummary = '',
  }) {
    final ai = result.aiResponse;
    final summary = sessionSummary.trim().isNotEmpty
        ? sessionSummary
        : ai.summary;

    return SoapNote(
      subjective: result.anonymizedText,
      objective: _sectionFromItems('Exercices', ai.exercises),
      assessment: _sectionFromItems(
        'Recommandations',
        ai.recommendations,
        fallback: summary,
      ),
      plan: [
        if (ai.precautions.isNotEmpty)
          _sectionFromItems('Precautions', ai.precautions),
        if (ai.evidenceLevel.trim().isNotEmpty)
          'Niveau de preuve : ${ai.evidenceLevel}',
        if (ai.sources.isNotEmpty) _sectionFromItems('Sources', ai.sources),
      ].where((section) => section.trim().isNotEmpty).join('\n\n'),
    );
  }

  String _sectionFromItems(
    String title,
    List<String> items, {
    String fallback = '',
  }) {
    if (items.isEmpty) {
      return fallback;
    }
    return '$title :\n${items.map((item) => '- $item').join('\n')}';
  }
}
