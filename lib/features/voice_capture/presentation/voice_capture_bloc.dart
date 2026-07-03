import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/audio/audio_capture_service.dart';
import 'package:medicail/core/error/failure.dart';
import 'package:medicail/core/utils/anonymization_helper.dart';
import 'package:medicail/core/utils/transcript_merge_helper.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/features/note_template/domain/utils/note_template_applicator.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_event.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_state.dart';

@injectable
class VoiceCaptureBloc extends Bloc<VoiceCaptureEvent, VoiceCaptureState> {
  VoiceCaptureBloc(
    this._audioCaptureService,
    this._recordingSessionRepository,
  ) : super(const VoiceCaptureInitial()) {
    on<VoiceCaptureInitializeRequested>(_onInitialize);
    on<VoiceCaptureStartRecording>(_onStartRecording);
    on<VoiceCaptureStopRecording>(_onStopRecording);
    on<VoiceCaptureFinishConsultation>(_onFinishConsultation);
    on<VoiceCaptureClearTranscript>(_onClearTranscript);
    on<VoiceCaptureDiscardConsultation>(_onDiscardConsultation);
    on<VoiceCaptureListeningSessionEnded>(_onListeningSessionEnded);
    on<VoiceCaptureTranscriptUpdated>(_onTranscriptUpdated);
    on<VoiceCaptureTemplateSelected>(_onTemplateSelected);
  }

  final AudioCaptureService _audioCaptureService;
  final RecordingSessionRepository _recordingSessionRepository;
  String _segmentBase = '';
  RecordingSession? _activeSession;
  NoteTemplate? _selectedTemplate;

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
          selectedTemplate: _selectedTemplate,
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
      emit(RecordingInProgress(
        transcript: currentTranscript,
        selectedTemplate: _selectedTemplate,
      ));
    } catch (error) {
      await _failActiveSession(currentTranscript);
      emit(
        VoiceCaptureFailure(
          Failure.fromException(error).message,
          transcript: currentTranscript,
          selectedTemplate: _selectedTemplate,
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
      emit(ListeningPaused(
        transcript: _currentTranscript,
        selectedTemplate: _selectedTemplate,
      ));
    } catch (error) {
      await _failActiveSession(_currentTranscript);
      emit(
        VoiceCaptureFailure(
          Failure.fromException(error).message,
          transcript: _currentTranscript,
          selectedTemplate: _selectedTemplate,
        ),
      );
    }
  }

  Future<void> _onFinishConsultation(
    VoiceCaptureFinishConsultation event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    final transcript = _currentTranscript;
    try {
      await _audioCaptureService.stopListening();
      final sessionId = _activeSession?.id ?? '';
      await _completeActiveSession(
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
          selectedTemplate: _selectedTemplate,
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
    emit(VoiceCaptureReady(selectedTemplate: _selectedTemplate));
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
    emit(VoiceCaptureReady(selectedTemplate: _selectedTemplate));
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
      emit(RecordingInProgress(
        transcript: transcript,
        selectedTemplate: _selectedTemplate,
      ));
    } catch (error) {
      await _failActiveSession(transcript);
      emit(
        VoiceCaptureFailure(
          Failure.fromException(error).message,
          transcript: transcript,
          selectedTemplate: _selectedTemplate,
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
    emit(RecordingInProgress(
      transcript: merged,
      selectedTemplate: _selectedTemplate,
    ));
  }

  void _onTemplateSelected(
    VoiceCaptureTemplateSelected event,
    Emitter<VoiceCaptureState> emit,
  ) {
    _selectedTemplate = event.template;
    final session = _activeSession;
    if (session != null) {
      _activeSession = session.copyWith(
        templateId: _selectedTemplate?.id,
        templateName: _selectedTemplate?.name,
        clearTemplateId: _selectedTemplate == null,
        clearTemplateName: _selectedTemplate == null,
      );
      _recordingSessionRepository.save(_activeSession!);
    }
    emit(_stateWithSelectedTemplate(_currentTranscript));
  }

  VoiceCaptureState _stateWithSelectedTemplate(String transcript) {
    return switch (state) {
      VoiceCaptureReady() => VoiceCaptureReady(
          transcript: transcript,
          selectedTemplate: _selectedTemplate,
        ),
      RecordingInProgress() => RecordingInProgress(
          transcript: transcript,
          selectedTemplate: _selectedTemplate,
        ),
      ListeningPaused() => ListeningPaused(
          transcript: transcript,
          selectedTemplate: _selectedTemplate,
        ),
      VoiceCaptureFailure(:final message) => VoiceCaptureFailure(
          message,
          transcript: transcript,
          selectedTemplate: _selectedTemplate,
        ),
      _ => VoiceCaptureReady(
          transcript: transcript,
          selectedTemplate: _selectedTemplate,
        ),
    };
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
      templateId: _selectedTemplate?.id,
      templateName: _selectedTemplate?.name,
    );
    _activeSession = session;
    await _recordingSessionRepository.save(_activeSession!);
  }

  Future<void> _completeActiveSession({
    required String transcript,
  }) async {
    final session = _activeSession;
    if (session == null) {
      return;
    }

    final completed = session.copyWith(
      endedAt: DateTime.now(),
      transcript: transcript,
      soapNote: session.soapNote ??
          NoteTemplateApplicator.apply(
            template: _selectedTemplate,
            transcript: transcript,
          ),
      status: RecordingSessionStatus.completed,
      templateId: _selectedTemplate?.id ?? session.templateId,
      templateName: _selectedTemplate?.name ?? session.templateName,
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
