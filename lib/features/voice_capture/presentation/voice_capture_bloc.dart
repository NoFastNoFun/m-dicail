import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/audio/audio_capture_service.dart';
import 'package:medicail/core/audio/background_audio_recorder.dart';
import 'package:medicail/core/audio/offline_audio_transcription_service.dart';
import 'package:medicail/core/audio/recording_notification_service.dart';
import 'package:medicail/core/error/failure.dart';
import 'package:medicail/core/utils/anonymization_helper.dart';
import 'package:medicail/core/utils/punctuation_helper.dart';
import 'package:medicail/core/utils/transcript_merge_helper.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';
import 'package:medicail/features/recording/domain/repositories/enhanced_transcription_repository.dart';
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
    this._enhancedTranscriptionRepository,
    this._recordingNotificationService,
    this._backgroundAudioRecorder,
    this._offlineAudioTranscriptionService,
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
    on<VoiceCaptureAppBackgrounded>(_onAppBackgrounded);
    on<VoiceCaptureAppForegrounded>(_onAppForegrounded);
  }

  final AudioCaptureService _audioCaptureService;
  final RecordingSessionRepository _recordingSessionRepository;
  final NoteProcessingRepository _noteProcessingRepository;
  final EnhancedTranscriptionRepository _enhancedTranscriptionRepository;
  final RecordingNotificationService _recordingNotificationService;
  final BackgroundAudioRecorder _backgroundAudioRecorder;
  final OfflineAudioTranscriptionService _offlineAudioTranscriptionService;

  String _segmentBase = '';
  RecordingSession? _activeSession;
  NoteTemplate? _selectedTemplate;
  bool _isBackgroundCapture = false;
  bool _isHandlingLifecycle = false;

  List<String> _transitions = const [];
  String _wordPeriod = '';
  String _wordComma = '';

  static const _notificationTitle = 'Ecoute en cours';
  static const _notificationBody = 'Touchez pour revenir a Medicail';
  static const _notificationBackgroundTitle =
      'Enregistrement en arriere-plan';
  static const _notificationBackgroundBody =
      "L'enregistrement audio continue pendant que l'ecran est eteint";

  Future<void> _onInitialize(
    VoiceCaptureInitializeRequested event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    try {
      await _audioCaptureService.initialize();
      await _recordingNotificationService.ensureInitialized();
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
    _transitions = event.transitions;
    _wordPeriod = event.wordPeriod;
    _wordComma = event.wordComma;
    try {
      await _audioCaptureService.initialize();
      await _ensureActiveSessionStarted(
        currentTranscript,
        patientId: event.patientId,
      );
      await _ensureSessionAudioStarted();
      await _recordingNotificationService.start(
        title: _notificationTitle,
        body: _notificationBody,
      );
      await _tryStartListeningSession();
      _isBackgroundCapture = false;
      emit(RecordingInProgress(
        transcript: currentTranscript,
        selectedTemplate: _selectedTemplate,
      ));
    } catch (error) {
      await _failActiveSession(currentTranscript);
      await _stopRecordingInfrastructure();
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
      await _stopListeningAndNotification();
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
    final roughTranscript = _currentTranscript;
    final sessionId = _activeSession?.id ?? '';

    if (sessionId.isEmpty) {
      emit(
        VoiceCaptureFailure(
          'Aucune session active',
          transcript: roughTranscript,
        ),
      );
      return;
    }

    String? audioPath;
    try {
      await _stopListeningAndNotification();
      audioPath = await _stopSessionAudio();

      var transcriptForProcess = roughTranscript;
      if (audioPath != null) {
        emit(VoiceCaptureEnhancing(transcript: roughTranscript));
        try {
          final enhanced = await _enhancedTranscriptionRepository.transcribeFile(
            filePath: audioPath,
            sessionId: sessionId,
            language: event.language,
          );
          if (enhanced.isNotEmpty) {
            transcriptForProcess = AnonymizationHelper.anonymize(enhanced);
            await _saveActiveSessionTranscript(transcriptForProcess);
          }
        } catch (_) {
          try {
            final offlineText = await _offlineAudioTranscriptionService
                .transcribeFile(audioPath, language: event.language);
            if (offlineText.isNotEmpty) {
              transcriptForProcess = AnonymizationHelper.anonymize(offlineText);
              await _saveActiveSessionTranscript(transcriptForProcess);
            }
          } catch (_) {
            transcriptForProcess = roughTranscript;
          }
        }
      }

      emit(VoiceCaptureProcessing(transcript: transcriptForProcess));

      final result = await _noteProcessingRepository.process(
        sessionId: sessionId,
        rawText: transcriptForProcess,
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
          transcript: roughTranscript,
          selectedTemplate: _selectedTemplate,
        ),
      );
    } finally {
      if (audioPath != null) {
        await _deleteAudioFile(audioPath);
      }
    }
  }

  void _onClearTranscript(
    VoiceCaptureClearTranscript event,
    Emitter<VoiceCaptureState> emit,
  ) {
    if (state is RecordingInProgress ||
        state is VoiceCaptureTranscribingBackground ||
        state is VoiceCaptureEnhancing) {
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
      await _stopRecordingInfrastructure();
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
    if (state is! RecordingInProgress || _isBackgroundCapture) {
      return;
    }

    var transcript = _currentTranscript.trim();
    if (transcript.isNotEmpty && !transcript.endsWith('.')) {
      transcript += '. ';
    }
    _segmentBase = transcript;
    try {
      await _saveActiveSessionTranscript(transcript);
      await _tryStartListeningSession();
      emit(RecordingInProgress(
        transcript: transcript,
        selectedTemplate: _selectedTemplate,
      ));
    } catch (error) {
      await _failActiveSession(transcript);
      await _stopRecordingInfrastructure();
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
    if (state is! RecordingInProgress || _isBackgroundCapture) {
      return;
    }

    final anonymized = AnonymizationHelper.anonymize(event.rawText);
    if (anonymized.isEmpty) {
      return;
    }

    final punctuated = PunctuationHelper.applyHeuristics(
      text: anonymized,
      wordPeriod: _wordPeriod,
      wordComma: _wordComma,
      transitionWords: _transitions,
    );

    final merged = TranscriptMergeHelper.merge(_segmentBase, punctuated);
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

  Future<void> _onAppBackgrounded(
    VoiceCaptureAppBackgrounded event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    if (_isHandlingLifecycle || _isBackgroundCapture) {
      return;
    }
    if (state is! RecordingInProgress) {
      return;
    }

    _isHandlingLifecycle = true;
    try {
      await _audioCaptureService.stopListening();
      await _ensureSessionAudioStarted();
      _isBackgroundCapture = true;
      await _recordingNotificationService.update(
        title: _notificationBackgroundTitle,
        body: _notificationBackgroundBody,
      );
      emit(RecordingInProgress(
        transcript: _currentTranscript,
        selectedTemplate: _selectedTemplate,
        isBackgroundCapture: true,
      ));
    } catch (error) {
      _isBackgroundCapture = false;
      await _failActiveSession(_currentTranscript);
      await _stopRecordingInfrastructure();
      emit(
        VoiceCaptureFailure(
          Failure.fromException(error).message,
          transcript: _currentTranscript,
          selectedTemplate: _selectedTemplate,
        ),
      );
    } finally {
      _isHandlingLifecycle = false;
    }
  }

  Future<void> _onAppForegrounded(
    VoiceCaptureAppForegrounded event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    if (_isHandlingLifecycle || !_isBackgroundCapture) {
      return;
    }
    if (state is! RecordingInProgress &&
        state is! VoiceCaptureTranscribingBackground) {
      return;
    }

    _isHandlingLifecycle = true;
    final baseTranscript = _currentTranscript;
    try {
      _isBackgroundCapture = false;
      await _recordingNotificationService.update(
        title: _notificationTitle,
        body: _notificationBody,
      );
      await _tryStartListeningSession();
      emit(RecordingInProgress(
        transcript: baseTranscript,
        selectedTemplate: _selectedTemplate,
      ));
    } catch (error) {
      _isBackgroundCapture = false;
      await _failActiveSession(baseTranscript);
      await _stopRecordingInfrastructure();
      emit(
        VoiceCaptureFailure(
          Failure.fromException(error).message,
          transcript: baseTranscript,
          selectedTemplate: _selectedTemplate,
        ),
      );
    } finally {
      _isHandlingLifecycle = false;
    }
  }

  VoiceCaptureState _stateWithSelectedTemplate(String transcript) {
    return switch (state) {
      VoiceCaptureReady() => VoiceCaptureReady(
          transcript: transcript,
          selectedTemplate: _selectedTemplate,
        ),
      RecordingInProgress(:final isBackgroundCapture) => RecordingInProgress(
          transcript: transcript,
          selectedTemplate: _selectedTemplate,
          isBackgroundCapture: isBackgroundCapture,
        ),
      VoiceCaptureTranscribingBackground() => VoiceCaptureTranscribingBackground(
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
      VoiceCaptureEnhancing() => VoiceCaptureEnhancing(transcript: transcript),
      VoiceCaptureProcessing() => VoiceCaptureProcessing(transcript: transcript),
      _ => VoiceCaptureReady(
          transcript: transcript,
          selectedTemplate: _selectedTemplate,
        ),
    };
  }

  Future<void> _tryStartListeningSession() async {
    try {
      await _audioCaptureService.startListening(
        onResult: (text) {
          if (isClosed || _isBackgroundCapture) {
            return;
          }
          add(VoiceCaptureTranscriptUpdated(text));
        },
        onListeningEnded: () {
          if (isClosed || _isBackgroundCapture) {
            return;
          }
          add(const VoiceCaptureListeningSessionEnded());
        },
      );
    } catch (_) {
      // Keep continuous WAV; rough live STT may be unavailable when the mic
      // cannot be shared with the session recorder.
    }
  }

  Future<void> _ensureSessionAudioStarted() async {
    if (_backgroundAudioRecorder.isRecording) {
      return;
    }
    final sessionId = _activeSession?.id ?? 'anonymous';
    await _backgroundAudioRecorder.start(sessionId: sessionId);
  }

  Future<String?> _stopSessionAudio() async {
    if (!_backgroundAudioRecorder.isRecording) {
      return null;
    }
    return _backgroundAudioRecorder.stop();
  }

  Future<void> _stopListeningAndNotification() async {
    await _audioCaptureService.stopListening();
    _isBackgroundCapture = false;
    await _recordingNotificationService.stop();
  }

  Future<void> _stopRecordingInfrastructure() async {
    try {
      await _audioCaptureService.stopListening();
    } catch (_) {}
    try {
      await _backgroundAudioRecorder.cancel();
    } catch (_) {}
    _isBackgroundCapture = false;
    try {
      await _recordingNotificationService.stop();
    } catch (_) {}
  }

  Future<void> _deleteAudioFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  String get _currentTranscript {
    return switch (state) {
      VoiceCaptureReady(:final transcript) => transcript,
      RecordingInProgress(:final transcript) => transcript,
      VoiceCaptureTranscribingBackground(:final transcript) => transcript,
      ListeningPaused(:final transcript) => transcript,
      VoiceCaptureFailure(:final transcript) => transcript,
      VoiceCaptureProcessing(:final transcript) => transcript,
      VoiceCaptureEnhancing(:final transcript) => transcript,
      VoiceCaptureConsultationFinished(:final transcript) => transcript,
      _ => '',
    };
  }

  String _generateSessionId(DateTime startedAt) {
    return 'local_recording_${startedAt.toUtc().microsecondsSinceEpoch}';
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
      id: _generateSessionId(startedAt),
      patientId: patientId,
      startedAt: startedAt,
      transcript: transcript,
      status: RecordingSessionStatus.recording,
      templateId: _selectedTemplate?.id,
      templateName: _selectedTemplate?.name,
    );
    _activeSession = await _recordingSessionRepository.save(session);
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
      templateId: _selectedTemplate?.id ?? session.templateId,
      templateName: _selectedTemplate?.name ?? session.templateName,
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
    _activeSession = await _recordingSessionRepository.save(failed);
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

  @override
  Future<void> close() async {
    await _stopRecordingInfrastructure();
    return super.close();
  }
}
