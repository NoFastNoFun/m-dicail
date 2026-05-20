import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/audio/audio_capture_service.dart';
import 'package:medicail/core/audio/raw_audio_recorder_service.dart';
import 'package:medicail/core/error/failure.dart';
import 'package:medicail/core/utils/anonymization_helper.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_event.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_state.dart';

@injectable
class VoiceCaptureBloc extends Bloc<VoiceCaptureEvent, VoiceCaptureState> {
  VoiceCaptureBloc(
    this._audioCaptureService,
    this._rawAudioRecorderService,
    this._recordingSessionRepository,
  ) : super(const VoiceCaptureInitial()) {
    on<VoiceCaptureInitializeRequested>(_onInitialize);
    on<VoiceCaptureStartRecording>(_onStartRecording);
    on<VoiceCaptureStopRecording>(_onStopRecording);
    on<VoiceCaptureClearTranscript>(_onClearTranscript);
    on<VoiceCaptureListeningSessionEnded>(_onListeningSessionEnded);
    on<VoiceCaptureTranscriptUpdated>(_onTranscriptUpdated);
  }

  final AudioCaptureService _audioCaptureService;
  final RawAudioRecorderService _rawAudioRecorderService;
  final RecordingSessionRepository _recordingSessionRepository;
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
    final startedAt = DateTime.now();
    final session = RecordingSession(
      id: _generateSessionId(startedAt),
      startedAt: startedAt,
      transcript: currentTranscript,
      status: RecordingSessionStatus.recording,
    );
    try {
      final rawAudioPath = await _rawAudioRecorderService.startRecording(
        sessionId: session.id,
      );
      _activeSession = session.copyWith(rawAudioPath: rawAudioPath);
      await _recordingSessionRepository.save(_activeSession!);
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
      final rawAudioPath = await _rawAudioRecorderService.stopRecording();
      await _completeActiveSession(rawAudioPath: rawAudioPath);
      _segmentBase = '';
      emit(VoiceCaptureReady(transcript: _currentTranscript));
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
      onResult: (text) => add(VoiceCaptureTranscriptUpdated(text)),
      onListeningEnded: () => add(const VoiceCaptureListeningSessionEnded()),
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
      _ => '',
    };
  }

  String _generateSessionId(DateTime startedAt) {
    return 'recording_${startedAt.toUtc().microsecondsSinceEpoch}';
  }

  Future<void> _completeActiveSession({String? rawAudioPath}) async {
    final session = _activeSession;
    if (session == null) {
      return;
    }

    final completed = session.copyWith(
      endedAt: DateTime.now(),
      rawAudioPath: rawAudioPath,
      transcript: _currentTranscript,
      status: RecordingSessionStatus.completed,
    );
    _activeSession = completed;
    await _recordingSessionRepository.save(completed);
  }

  Future<void> _failActiveSession(String transcript) async {
    try {
      await _rawAudioRecorderService.cancelRecording();
    } catch (_) {}

    final session = _activeSession;
    if (session == null) {
      return;
    }

    final failed = session.copyWith(
      endedAt: DateTime.now(),
      transcript: transcript,
      status: RecordingSessionStatus.failed,
      clearRawAudioPath: true,
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
}
