import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/audio/audio_capture_service.dart';
import 'package:medicail/core/error/failure.dart';
import 'package:medicail/core/utils/anonymization_helper.dart';
import 'package:medicail/core/utils/transcript_merge_helper.dart';
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
  ) : super(const VoiceCaptureInitial()) {
    on<VoiceCaptureInitializeRequested>(_onInitialize);
    on<VoiceCaptureStartRecording>(_onStartRecording);
    on<VoiceCaptureStopRecording>(_onStopRecording);
    on<VoiceCaptureFinishConsultation>(_onFinishConsultation);
    on<VoiceCaptureClearTranscript>(_onClearTranscript);
    on<VoiceCaptureDiscardConsultation>(_onDiscardConsultation);
    on<VoiceCaptureListeningSessionEnded>(_onListeningSessionEnded);
    on<VoiceCaptureTranscriptUpdated>(_onTranscriptUpdated);
  }

  final AudioCaptureService _audioCaptureService;
  final RecordingSessionRepository _recordingSessionRepository;
  final NoteProcessingRepository _noteProcessingRepository;
  String _segmentBase = '';
  RecordingSession? _activeSession;

  Future<void> _onInitialize(
    VoiceCaptureInitializeRequested event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    try {
      await _audioCaptureService.initialize();
      emit(const VoiceCaptureReady());
    } catch (error) {
      emit(
        VoiceCaptureFailure(
          Failure.fromException(error).message,
          transcript: _currentTranscript,
        ),
      );
    }
  }

  Future<void> _onStartRecording(
    VoiceCaptureStartRecording event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    final currentTranscript = _currentTranscript;
    _segmentBase = currentTranscript;
    try {
      _log('start:requested');
      await _audioCaptureService.initialize();
      _log('start:audio-initialized');
      await _startListeningSession();
      _log('start:listening-requested');
      emit(RecordingInProgress(transcript: currentTranscript));
      _log('start:creating-backend-session');
      await _ensureActiveSessionStarted(
        currentTranscript,
        patientId: event.patientId,
      );
      _log('start:session-created id=${_activeSession?.id}');
    } catch (error, stackTrace) {
      _log('start:failure error=$error');
      if (kDebugMode) {
        debugPrintStack(stackTrace: stackTrace);
      }
      await _stopListeningSafely();
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
      emit(
        VoiceCaptureConsultationFinished(
          sessionId: sessionId,
          transcript: transcript,
        ),
      );
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

  Future<void> _onDiscardConsultation(
    VoiceCaptureDiscardConsultation event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    try {
      await _audioCaptureService.stopListening();
    } catch (_) {
      // Best effort when abandoning an in-progress session.
    }

    final session = _activeSession;
    if (session != null) {
      await _recordingSessionRepository.delete(session.id);
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
      await _saveActiveSessionTranscript(transcript);
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

  void _onTranscriptUpdated(
    VoiceCaptureTranscriptUpdated event,
    Emitter<VoiceCaptureState> emit,
  ) {
    if (state is! RecordingInProgress) {
      return;
    }

    final anonymized = AnonymizationHelper.anonymize(event.rawText);
    if (anonymized.isEmpty) {
      return;
    }

    final merged = TranscriptMergeHelper.merge(_segmentBase, anonymized);
    _updateActiveSessionTranscriptInMemory(merged);
    emit(RecordingInProgress(transcript: merged));
  }

  Future<void> _startListeningSession() {
    return _audioCaptureService.startListening(
      onResult: (text) {
        if (isClosed) {
          return;
        }
        add(VoiceCaptureTranscriptUpdated(text));
      },
      onListeningEnded: () {
        if (isClosed) {
          return;
        }
        add(const VoiceCaptureListeningSessionEnded());
      },
    );
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

  Future<void> _ensureActiveSessionStarted(
    String transcript, {
    String? patientId,
  }) async {
    final existingSession = _activeSession;
    if (existingSession != null &&
        existingSession.status == RecordingSessionStatus.recording) {
      final updated = existingSession.copyWith(transcript: transcript);
      _activeSession = await _recordingSessionRepository.save(updated);
      return;
    }

    final startedAt = DateTime.now();
    final session = RecordingSession(
      id: '',
      patientId: patientId,
      startedAt: startedAt,
      transcript: transcript,
      status: RecordingSessionStatus.recording,
    );
    _activeSession = await _recordingSessionRepository.create(session);
  }

  Future<void> _completeActiveSession({
    required String sessionId,
    required String transcript,
  }) async {
    final session = _activeSession;
    if (session == null) {
      return;
    }

    final processedNote = await _processTranscript(
      sessionId: sessionId,
      transcript: transcript,
    );

    final completed = session.copyWith(
      endedAt: DateTime.now(),
      transcript: transcript,
      soapNote: processedNote.soapNote,
      summary: processedNote.summary,
      status: RecordingSessionStatus.completed,
    );
    _activeSession = await _recordingSessionRepository.save(completed);
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

  void _updateActiveSessionTranscriptInMemory(String transcript) {
    final session = _activeSession;
    if (session == null) {
      return;
    }

    _activeSession = session.copyWith(transcript: transcript);
  }

  Future<void> _saveActiveSessionTranscript(String transcript) async {
    final session = _activeSession;
    if (session == null) {
      return;
    }

    final updated = session.copyWith(transcript: transcript);
    _activeSession = await _recordingSessionRepository.save(updated);
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

  Future<_ProcessedNote> _processTranscript({
    required String sessionId,
    required String transcript,
  }) async {
    final cleanTranscript = transcript.trim();
    if (cleanTranscript.isEmpty) {
      return _ProcessedNote(
        soapNote: _generateMockSoapNote(cleanTranscript),
        summary: '',
      );
    }

    final result = await _noteProcessingRepository.processNote(
      sessionId: sessionId,
      rawText: cleanTranscript,
    );
    final sessionSummary = await _noteProcessingRepository.summarizeNote(
      sessionId: sessionId,
      processedText: result.processedText,
    );

    return _ProcessedNote(
      soapNote: _generateMockSoapNote(result.processedText),
      summary: sessionSummary,
    );
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[VoiceCapture] $message');
    }
  }
}

final class _ProcessedNote {
  const _ProcessedNote({required this.soapNote, required this.summary});

  final SoapNote soapNote;
  final String summary;
}
