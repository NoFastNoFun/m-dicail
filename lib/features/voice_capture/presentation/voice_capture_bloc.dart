import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/audio/audio_capture_service.dart';
import 'package:medicail/core/error/failure.dart';
import 'package:medicail/core/utils/anonymization_helper.dart';
import 'package:medicail/core/utils/punctuation_helper.dart';
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
    
    if (sessionId.isEmpty) {
      emit(VoiceCaptureFailure('Aucune session active', transcript: transcript));
      return;
    }

    try {
      await _audioCaptureService.stopListening();
      emit(VoiceCaptureProcessing(transcript: transcript));

      final result = await _noteProcessingRepository.process(
        sessionId: sessionId,
        rawText: transcript,
        language: event.language,
      );

      await _completeActiveSession(
        transcript: result.processedText,
        soapNote: result.soapNote,
      );
      
      _segmentBase = '';
      _activeSession = null;
      emit(VoiceCaptureConsultationFinished(
        sessionId: sessionId,
        transcript: result.processedText,
      ));
    } catch (error) {
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

    var transcript = _currentTranscript.trim();
    if (transcript.isNotEmpty && !transcript.endsWith('.')) {
      transcript += '. ';
    }
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

    final punctuated = PunctuationHelper.applyHeuristics(anonymized);

    final merged = TranscriptMergeHelper.merge(_segmentBase, punctuated);
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
    required String transcript,
    required SoapNote soapNote,
  }) async {
    final session = _activeSession;
    if (session == null) {
      return;
    }

    final completed = session.copyWith(
      endedAt: DateTime.now(),
      transcript: transcript,
      soapNote: soapNote,
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
    _activeSession = updated;
    await _recordingSessionRepository.save(updated);
  }
}
