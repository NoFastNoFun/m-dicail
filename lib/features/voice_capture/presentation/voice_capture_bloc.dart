import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/audio/audio_capture_service.dart';
import 'package:medicail/core/audio/background_audio_recorder.dart';
import 'package:medicail/core/audio/offline_audio_transcription_service.dart';
import 'package:medicail/core/audio/recording_notification_service.dart';
import 'package:medicail/core/error/failure.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:medicail/core/medical_terms/medical_term_correction_service.dart';
import 'package:medicail/core/utils/anonymization_helper.dart';
import 'package:medicail/core/utils/punctuation_helper.dart';
import 'package:medicail/core/utils/transcript_merge_helper.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/features/note_template/domain/utils/note_template_applicator.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/entities/session_pathology.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';
import 'package:medicail/features/recording/domain/repositories/enhanced_transcription_repository.dart';
import 'package:medicail/features/recording/domain/repositories/note_processing_repository.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:medicail/features/settings/domain/repositories/user_preferences_repository.dart';
import 'package:medicail/features/voice_capture/presentation/ai_transcription_job_cubit.dart';
import 'package:medicail/features/voice_capture/presentation/ai_transcription_job_state.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_event.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_state.dart';

import 'package:medicail/core/telemetry/telemetry_service.dart';

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
    this._medicalTermCorrectionService,
    this._userPreferencesRepository,
    this._telemetryService,
    this._aiTranscriptionJobCubit,
  ) : super(const VoiceCaptureInitial()) {
    on<VoiceCaptureInitializeRequested>(_onInitialize);
    on<VoiceCaptureStartRecording>(_onStartRecording);
    on<VoiceCaptureStopRecording>(_onStopRecording);
    on<VoiceCaptureFinishConsultation>(_onFinishConsultation);
    on<VoiceCaptureAiTranscriptionCompleted>(_onAiTranscriptionCompleted);
    on<VoiceCaptureAiTranscriptionLocalOnly>(_onAiTranscriptionLocalOnly);
    on<VoiceCaptureAiTranscriptionFailed>(_onAiTranscriptionFailed);
    on<VoiceCaptureTranscriptChoiceSelected>(_onTranscriptChoiceSelected);
    on<VoiceCaptureClearTranscript>(_onClearTranscript);
    on<VoiceCaptureDiscardConsultation>(_onDiscardConsultation);
    on<VoiceCaptureListeningSessionEnded>(_onListeningSessionEnded);
    on<VoiceCaptureTranscriptUpdated>(_onTranscriptUpdated);
    on<VoiceCaptureTemplateSelected>(_onTemplateSelected);
    on<VoiceCaptureAppBackgrounded>(_onAppBackgrounded);
    on<VoiceCaptureAppForegrounded>(_onAppForegrounded);
    on<VoiceCaptureAiChunkTick>(_onAiChunkTick);
    on<VoiceCaptureScratchNotesUpdated>(_onScratchNotesUpdated);
  }

  final AudioCaptureService _audioCaptureService;
  final RecordingSessionRepository _recordingSessionRepository;
  final NoteProcessingRepository _noteProcessingRepository;
  final EnhancedTranscriptionRepository _enhancedTranscriptionRepository;
  final RecordingNotificationService _recordingNotificationService;
  final BackgroundAudioRecorder _backgroundAudioRecorder;
  final OfflineAudioTranscriptionService _offlineAudioTranscriptionService;
  final MedicalTermCorrectionService _medicalTermCorrectionService;
  final UserPreferencesRepository _userPreferencesRepository;
  final TelemetryService _telemetryService;
  final AiTranscriptionJobCubit _aiTranscriptionJobCubit;

  RecordingSession? _activeSession;
  bool _isHandlingLifecycle = false;
  bool _isBackgroundCapture = false;
  bool _captureForAi = false;
  bool _isDiscarding = false;
  int _discardGeneration = 0;
  String _segmentBase = '';
  String _lastRawText = '';
  NoteTemplate? _selectedTemplate;
  String _pendingFinishLanguage = 'fr';
  StreamSubscription<AiTranscriptionJobState>? _jobSubscription;
  String _userScratchNotes = '';
  Duration _recordingDuration = Duration.zero;
  Timer? _aiChunkTimer;
  int _nextChunkIndex = 0;
  final Map<int, Future<String?>> _inflightChunkFutures = {};
  final Map<int, String> _completedChunkTexts = {};
  static const _aiChunkInterval = Duration(seconds: 25);

  List<String> _transitions = const [];
  String _wordPeriod = '';
  String _wordComma = '';

  static const _notificationTitle = 'Ecoute en cours';
  static const _notificationBody = 'Touchez pour revenir a Medicail';
  static const _notificationBackgroundTitle = 'Enregistrement en arriere-plan';
  static const _notificationBackgroundBody =
      "L'enregistrement audio continue pendant que l'ecran est eteint";
  static const _micReleaseDelay = Duration(milliseconds: 250);

  Future<void> _onInitialize(
    VoiceCaptureInitializeRequested event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    try {
      if (!await _userPreferencesRepository.readAiEnhanceEnabled()) {
        await _audioCaptureService.initialize();
      }
      await _recordingNotificationService.ensureInitialized();
      await _medicalTermCorrectionService.warmUp();

      if (await _tryRestoreAiJob(emit)) {
        return;
      }

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

  /// Restores an in-flight or ready AI job when the record page is reopened.
  Future<bool> _tryRestoreAiJob(Emitter<VoiceCaptureState> emit) async {
    final job = _aiTranscriptionJobCubit.state;
    switch (job) {
      case AiTranscriptionJobRunning(
        :final sessionId,
        :final roughTranscript,
        :final selectedTemplate,
        :final startedAt,
        :final estimatedDuration,
        :final language,
      ):
        final session = await _recordingSessionRepository.getById(sessionId);
        if (session == null) return false;
        _activeSession = session;
        _selectedTemplate = selectedTemplate ?? _selectedTemplate;
        _pendingFinishLanguage = language;
        _segmentBase = roughTranscript;
        _subscribeToAiJob();
        emit(
          VoiceCaptureAiTranscribing(
            transcript: roughTranscript,
            sessionId: sessionId,
            startedAt: startedAt,
            estimatedDuration: estimatedDuration,
            selectedTemplate: _selectedTemplate,
          ),
        );
        return true;
      case AiTranscriptionJobReady(
        :final sessionId,
        :final localTranscript,
        :final aiTranscript,
        :final selectedTemplate,
        :final language,
      ):
        final session = await _recordingSessionRepository.getById(sessionId);
        if (session == null) return false;
        _activeSession = session;
        _selectedTemplate = selectedTemplate ?? _selectedTemplate;
        _pendingFinishLanguage = language;
        await _aiTranscriptionJobCubit.markCompareOpened();
        _aiTranscriptionJobCubit.acknowledge();
        emit(
          VoiceCaptureTranscriptCompare(
            localTranscript: localTranscript,
            aiTranscript: aiTranscript,
            selectedTemplate: _selectedTemplate,
          ),
        );
        return true;
      case AiTranscriptionJobCompletedWithoutCompare(
        :final sessionId,
        :final transcript,
        :final selectedTemplate,
        :final language,
      ):
        final session = await _recordingSessionRepository.getById(sessionId);
        if (session == null) return false;
        _activeSession = session;
        _selectedTemplate = selectedTemplate ?? _selectedTemplate;
        _pendingFinishLanguage = language;
        _aiTranscriptionJobCubit.acknowledge();
        await _finalizeConsultation(
          emit: emit,
          sessionId: sessionId,
          transcriptForProcess: transcript,
          language: language,
          transcriptIsAi: false,
          uxStopwatch: Stopwatch()..start(),
        );
        return true;
      case AiTranscriptionJobFailed(
        :final sessionId,
        :final message,
        :final roughTranscript,
        :final selectedTemplate,
      ):
        final session = await _recordingSessionRepository.getById(sessionId);
        if (session != null) {
          _activeSession = session;
        }
        _selectedTemplate = selectedTemplate ?? _selectedTemplate;
        _aiTranscriptionJobCubit.acknowledge();
        emit(
          VoiceCaptureFailure(
            message,
            transcript: roughTranscript,
            selectedTemplate: _selectedTemplate,
          ),
        );
        return true;
      case AiTranscriptionJobIdle():
        return false;
    }
  }

  void _subscribeToAiJob() {
    _jobSubscription?.cancel();
    _jobSubscription = _aiTranscriptionJobCubit.stream.listen((jobState) {
      if (isClosed) return;
      switch (jobState) {
        case AiTranscriptionJobReady(
          :final localTranscript,
          :final aiTranscript,
        ):
          add(
            VoiceCaptureAiTranscriptionCompleted(
              localTranscript: localTranscript,
              aiTranscript: aiTranscript,
            ),
          );
        case AiTranscriptionJobCompletedWithoutCompare(:final transcript):
          add(VoiceCaptureAiTranscriptionLocalOnly(transcript: transcript));
        case AiTranscriptionJobFailed(:final message):
          add(VoiceCaptureAiTranscriptionFailed(message: message));
        default:
          break;
      }
    });
  }

  Future<void> _cancelJobSubscription() async {
    await _jobSubscription?.cancel();
    _jobSubscription = null;
  }

  Future<void> _onStartRecording(
    VoiceCaptureStartRecording event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    if (_aiTranscriptionJobCubit.isBusy) {
      emit(
        VoiceCaptureFailure(
          'Une transcription est deja en cours.',
          transcript: _currentTranscript,
          selectedTemplate: _selectedTemplate,
        ),
      );
      return;
    }
    final currentTranscript = _currentTranscript;
    _segmentBase = currentTranscript;
    _transitions = event.transitions;
    _wordPeriod = event.wordPeriod;
    _wordComma = event.wordComma;
    try {
      // Keep one capture mode throughout a consultation, including pauses.
      if (_activeSession == null) {
        _captureForAi = await _userPreferencesRepository.readAiEnhanceEnabled();
      }
      if (!_captureForAi) {
        await _audioCaptureService.initialize();
      }
      await _ensureActiveSessionStarted(
        currentTranscript,
        patientId: event.patientId,
      );
      await _recordingNotificationService.start(
        title: _notificationTitle,
        body: _notificationBody,
      );
      if (_captureForAi) {
        await _backgroundAudioRecorder.start(sessionId: _activeSession!.id);
      } else {
        await _startListeningSession();
      }
      _isBackgroundCapture = false;
      if (_captureForAi) {
        _startAiChunkTimer();
      }
      emit(
        RecordingInProgress(
          transcript: currentTranscript,
          selectedTemplate: _selectedTemplate,
          isAiCapture: _captureForAi,
        ),
      );
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
      _stopAiChunkTimer();
      await _stopListeningAndNotification();
      if (_captureForAi) {
        await _backgroundAudioRecorder.pause();
      } else {
        await _discardSessionAudio();
      }
      await _saveActiveSessionTranscript(_currentTranscript);
      var transcript = _currentTranscript.trim();
      if (transcript.isNotEmpty && !transcript.endsWith('.')) {
        transcript += '. ';
      } else if (transcript.isNotEmpty) {
        transcript += ' ';
      }
      _segmentBase = transcript;
      _lastRawText = '';
      emit(
        ListeningPaused(
          transcript: _currentTranscript,
          selectedTemplate: _selectedTemplate,
          isAiCapture: _captureForAi,
        ),
      );
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
    final uxStopwatch = Stopwatch()..start();

    var roughTranscript = _currentTranscript;
    if (event.isTutorial && roughTranscript.trim().isEmpty) {
      roughTranscript = 'Voici une consultation fictive pour le tutoriel.';
      _segmentBase = roughTranscript;
      _updateActiveSessionTranscriptInMemory(roughTranscript);
    }

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

    _pendingFinishLanguage = event.language;
    _recordingDuration = event.recordingDuration;
    _stopAiChunkTimer();

    final pendingAudioPaths = <String>[];
    try {
      await _stopListeningAndNotification();

      final aiEnhanceEnabled = await _userPreferencesRepository
          .readAiEnhanceEnabled();

      if (_captureForAi && aiEnhanceEnabled) {
        await _finishAiProgressiveConsultation(
          emit: emit,
          sessionId: sessionId,
          language: event.language,
          roughTranscript: roughTranscript,
          uxStopwatch: uxStopwatch,
          pendingAudioPaths: pendingAudioPaths,
        );
        return;
      }

      var transcriptForProcess = roughTranscript;
      final audioPath = await _stopSessionAudio();
      if (_captureForAi && audioPath == null) {
        throw const AudioException(
          'Aucun fichier audio disponible pour la transcription.',
        );
      }
      if (audioPath != null) {
        // Background AI path: hand off and unlock the record UI.
        if (aiEnhanceEnabled && !event.isTutorial) {
          final estimated = AiTranscriptionJobCubit.estimateDuration(
            event.recordingDuration,
          );
          final startedAt = DateTime.now();
          emit(
            VoiceCaptureAiTranscribing(
              transcript: roughTranscript,
              sessionId: sessionId,
              startedAt: startedAt,
              estimatedDuration: estimated,
              selectedTemplate: _selectedTemplate,
            ),
          );
          _subscribeToAiJob();
          unawaited(
            _aiTranscriptionJobCubit.start(
              sessionId: sessionId,
              audioPath: audioPath,
              language: event.language,
              roughTranscript: roughTranscript,
              audioDuration: event.recordingDuration,
              patientId: _activeSession?.patientId,
              selectedTemplate: _selectedTemplate,
            ),
          );
          // WAV ownership transferred to the cubit.
          return;
        }

        pendingAudioPaths.add(audioPath);
        String? enhanced;
        if (aiEnhanceEnabled) {
          emit(
            VoiceCaptureEnhancing(
              transcript: roughTranscript,
              recordingDuration: _recordingDuration,
            ),
          );
          try {
            enhanced = await _enhancedTranscriptionRepository.transcribeFile(
              filePath: audioPath,
              sessionId: sessionId,
              language: event.language,
            );
          } catch (_) {
            // A local transcription remains available when the network fails.
          }
        }
        // Always try offline Whisper here so the compare panel still has a
        // local side when cloud enhance succeeds (local-STT / offline path).
        try {
          final offlineText = await _offlineAudioTranscriptionService
              .transcribeFile(audioPath, language: event.language);
          if (offlineText.isNotEmpty) {
            transcriptForProcess = AnonymizationHelper.anonymize(offlineText);
          }
        } catch (_) {
          // Keep the existing transcript or the successful cloud result.
        }
        if (enhanced != null && enhanced.trim().isNotEmpty) {
          // Offline / local+AI path: keep compare panel.
          emit(
            VoiceCaptureTranscriptCompare(
              localTranscript: transcriptForProcess,
              aiTranscript: AnonymizationHelper.anonymize(enhanced),
              selectedTemplate: _selectedTemplate,
            ),
          );
          return;
        }
        if (_captureForAi && transcriptForProcess.trim().isEmpty) {
          throw const AudioException(
            'La transcription a échoué ou ne contient aucune parole. Veuillez réessayer.',
          );
        }
      }

      await _finalizeConsultation(
        emit: emit,
        sessionId: sessionId,
        transcriptForProcess: transcriptForProcess,
        language: event.language,
        transcriptIsAi: false,
        uxStopwatch: uxStopwatch,
      );
    } catch (error) {
      final draft = _currentTranscript.trim().isNotEmpty
          ? _currentTranscript
          : roughTranscript;
      emit(
        VoiceCaptureFailure.fromException(
          error,
          transcript: draft,
          selectedTemplate: _selectedTemplate,
        ),
      );
    } finally {
      for (final path in pendingAudioPaths) {
        await _deleteAudioFile(path);
      }
    }
  }

  Future<void> _onAiTranscriptionCompleted(
    VoiceCaptureAiTranscriptionCompleted event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    await _cancelJobSubscription();
    await _aiTranscriptionJobCubit.markCompareOpened();
    _aiTranscriptionJobCubit.acknowledge();
    emit(
      VoiceCaptureTranscriptCompare(
        localTranscript: event.localTranscript,
        aiTranscript: event.aiTranscript,
        selectedTemplate: _selectedTemplate,
      ),
    );
  }

  Future<void> _onAiTranscriptionLocalOnly(
    VoiceCaptureAiTranscriptionLocalOnly event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    await _cancelJobSubscription();
    _aiTranscriptionJobCubit.acknowledge();
    final sessionId = _activeSession?.id ?? '';
    if (sessionId.isEmpty) {
      emit(
        VoiceCaptureFailure(
          'Aucune session active',
          transcript: event.transcript,
          selectedTemplate: _selectedTemplate,
        ),
      );
      return;
    }
    try {
      await _finalizeConsultation(
        emit: emit,
        sessionId: sessionId,
        transcriptForProcess: event.transcript,
        language: _pendingFinishLanguage,
        transcriptIsAi: false,
        uxStopwatch: Stopwatch()..start(),
      );
    } catch (error) {
      emit(
        VoiceCaptureFailure.fromException(
          error,
          transcript: event.transcript,
          selectedTemplate: _selectedTemplate,
        ),
      );
    }
  }

  Future<void> _onAiTranscriptionFailed(
    VoiceCaptureAiTranscriptionFailed event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    await _cancelJobSubscription();
    _aiTranscriptionJobCubit.acknowledge();
    emit(
      VoiceCaptureFailure(
        event.message,
        transcript: _currentTranscript,
        selectedTemplate: _selectedTemplate,
      ),
    );
  }

  Future<void> _onTranscriptChoiceSelected(
    VoiceCaptureTranscriptChoiceSelected event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    final uxStopwatch = Stopwatch()..start();

    final current = state;
    if (current is! VoiceCaptureTranscriptCompare) {
      return;
    }

    final sessionId = _activeSession?.id ?? '';
    if (sessionId.isEmpty) {
      emit(
        VoiceCaptureFailure(
          'Aucune session active',
          transcript: current.localTranscript,
          selectedTemplate: current.selectedTemplate,
        ),
      );
      return;
    }

    final chosen = event.useAi ? current.aiTranscript : current.localTranscript;
    final transcriptIsAi = event.useAi;

    try {
      final anonymized = AnonymizationHelper.anonymize(chosen);
      await _saveActiveSessionTranscript(
        anonymized,
        transcriptIsAi: transcriptIsAi,
      );
      await _finalizeConsultation(
        emit: emit,
        sessionId: sessionId,
        transcriptForProcess: anonymized,
        language: _pendingFinishLanguage,
        transcriptIsAi: transcriptIsAi,
        uxStopwatch: uxStopwatch,
      );
    } catch (error) {
      emit(
        VoiceCaptureFailure.fromException(
          error,
          transcript: chosen,
          selectedTemplate: _selectedTemplate,
        ),
      );
    }
  }

  Future<void> _finalizeConsultation({
    required Emitter<VoiceCaptureState> emit,
    required String sessionId,
    required String transcriptForProcess,
    required String language,
    required bool transcriptIsAi,
    required Stopwatch uxStopwatch,
  }) async {
    transcriptForProcess = await _medicalTermCorrectionService.correct(
      transcriptForProcess,
    );

    emit(VoiceCaptureProcessing(transcript: transcriptForProcess));

    // The HTTP repository owns the timeout (SOAP generation can exceed a minute).
    final result = await _noteProcessingRepository.process(
      sessionId: sessionId,
      rawText: transcriptForProcess,
      language: language,
    );

    final soapNote = !result.isAiGenerated && _selectedTemplate != null
        ? NoteTemplateApplicator.apply(
            template: _selectedTemplate,
            transcript: result.processedText,
          )
        : result.soapNote;

    await _completeActiveSession(
      transcript: result.processedText,
      soapNote: soapNote,
      transcriptIsAi: transcriptIsAi,
    );

    uxStopwatch.stop();

    _segmentBase = '';
    _lastRawText = '';
    _activeSession = null;
    emit(
      VoiceCaptureConsultationFinished(
        sessionId: sessionId,
        transcript: result.processedText,
        soapGeneratedByAi: result.isAiGenerated,
      ),
    );

    // Envoi de la télémétrie en arrière-plan
    _telemetryService.sendSoapGenerationTime(
      durationMs: uxStopwatch.elapsedMilliseconds,
      isAiGenerated: result.isAiGenerated,
    );
  }

  void _onClearTranscript(
    VoiceCaptureClearTranscript event,
    Emitter<VoiceCaptureState> emit,
  ) {
    if (state is RecordingInProgress ||
        state is VoiceCaptureTranscribingBackground ||
        state is VoiceCaptureAiTranscribing ||
        state is VoiceCaptureEnhancing ||
        state is VoiceCaptureTranscriptCompare) {
      return;
    }
    _segmentBase = '';
    _lastRawText = '';
    _activeSession = null;
    _resetAiChunkState();
    emit(VoiceCaptureReady(selectedTemplate: _selectedTemplate));
  }

  Future<void> _onDiscardConsultation(
    VoiceCaptureDiscardConsultation event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    if (_isDiscarding) return;
    _isDiscarding = true;
    // Invalidate callbacks and asynchronous corrections from this consultation
    // before stopping the microphone, which can deliver a final result.
    _discardGeneration++;
    final transcript = _currentTranscript;
    try {
      await _stopRecordingInfrastructure();
      final session = _activeSession;
      if (session != null) {
        await _recordingSessionRepository.delete(session.id);
      }

      _segmentBase = '';
      _lastRawText = '';
      _activeSession = null;
      _resetAiChunkState();
      emit(VoiceCaptureReady(selectedTemplate: _selectedTemplate));
    } catch (error) {
      emit(
        VoiceCaptureFailure.fromException(
          error,
          transcript: transcript,
          selectedTemplate: _selectedTemplate,
        ),
      );
    } finally {
      _isDiscarding = false;
    }
  }

  Future<void> _onListeningSessionEnded(
    VoiceCaptureListeningSessionEnded event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    if (_isDiscarding ||
        state is! RecordingInProgress ||
        _isBackgroundCapture ||
        _captureForAi) {
      return;
    }

    final generation = _discardGeneration;
    var transcript = _currentTranscript.trim();
    if (transcript.isNotEmpty && !transcript.endsWith('.')) {
      transcript += '. ';
    } else if (transcript.isNotEmpty) {
      transcript += ' ';
    }
    _segmentBase = transcript;
    _lastRawText = '';
    try {
      await _saveActiveSessionTranscript(transcript);
      if (_isDiscarding || generation != _discardGeneration) return;
      await _startListeningSession();
      if (_isDiscarding || generation != _discardGeneration) return;
      emit(
        RecordingInProgress(
          transcript: transcript,
          selectedTemplate: _selectedTemplate,
        ),
      );
    } catch (error) {
      if (_isDiscarding || generation != _discardGeneration) return;
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

  Future<void> _onTranscriptUpdated(
    VoiceCaptureTranscriptUpdated event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    if (_isDiscarding ||
        state is! RecordingInProgress ||
        _isBackgroundCapture ||
        _captureForAi) {
      return;
    }

    final generation = _discardGeneration;
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

    if (_lastRawText.isNotEmpty && event.rawText.isNotEmpty) {
      final maxOverlap = _lastRawText.length < event.rawText.length
          ? _lastRawText.length
          : event.rawText.length;

      bool hasOverlap = false;
      if (event.rawText.startsWith(_lastRawText) ||
          _lastRawText.startsWith(event.rawText)) {
        hasOverlap = true;
      } else {
        for (var overlap = maxOverlap; overlap > 0; overlap--) {
          if (_lastRawText.endsWith(event.rawText.substring(0, overlap))) {
            hasOverlap = true;
            break;
          }
        }
      }

      if (!hasOverlap) {
        var currentTranscript = _currentTranscript.trim();
        if (currentTranscript.isNotEmpty && !currentTranscript.endsWith('.')) {
          currentTranscript += '. ';
        } else if (currentTranscript.isNotEmpty) {
          currentTranscript += ' ';
        }
        _segmentBase = currentTranscript;
      }
    }
    _lastRawText = event.rawText;

    final merged = TranscriptMergeHelper.merge(_segmentBase, punctuated);
    final corrected = await _medicalTermCorrectionService.correct(merged);
    if (_isDiscarding || generation != _discardGeneration) return;
    _updateActiveSessionTranscriptInMemory(corrected);

    if (event.isFinal) {
      var finalTranscript = corrected.trim();
      if (finalTranscript.isNotEmpty && !finalTranscript.endsWith('.')) {
        finalTranscript += '. ';
      } else if (finalTranscript.isNotEmpty) {
        finalTranscript += ' ';
      }
      _segmentBase = finalTranscript;
      _lastRawText = ''; // Reset so the next text doesn't overlap with nothing
    }

    emit(
      RecordingInProgress(
        transcript: corrected,
        selectedTemplate: _selectedTemplate,
      ),
    );
  }

  void _onTemplateSelected(
    VoiceCaptureTemplateSelected event,
    Emitter<VoiceCaptureState> emit,
  ) {
    _selectedTemplate = event.template;
    final session = _activeSession;
    if (session != null) {
      final template = _selectedTemplate;
      final pathologies = template == null
          ? const <SessionPathology>[]
          : [
              SessionPathology(
                id: template.pathologyId ?? template.pathologyKey,
                name: template.name,
                templateId: template.id,
              ),
            ];
      _activeSession = session.copyWith(
        templateId: template?.id,
        templateName: template?.name,
        pathologies: pathologies,
        clearTemplateId: template == null,
        clearTemplateName: template == null,
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
      await _awaitMicRelease();
      await _ensureSessionAudioStarted();
      _isBackgroundCapture = true;
      await _recordingNotificationService.update(
        title: _notificationBackgroundTitle,
        body: _notificationBackgroundBody,
      );
      emit(
        RecordingInProgress(
          transcript: _currentTranscript,
          selectedTemplate: _selectedTemplate,
          isBackgroundCapture: true,
          isAiCapture: _captureForAi,
        ),
      );
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
      if (_captureForAi) {
        // The same WAV continues recording while the screen is off.
        _isBackgroundCapture = false;
        await _recordingNotificationService.update(
          title: _notificationTitle,
          body: _notificationBody,
        );
        emit(
          RecordingInProgress(
            transcript: baseTranscript,
            selectedTemplate: _selectedTemplate,
            isAiCapture: true,
          ),
        );
        return;
      }
      emit(
        VoiceCaptureTranscribingBackground(
          transcript: baseTranscript,
          selectedTemplate: _selectedTemplate,
        ),
      );

      final audioPath = await _stopSessionAudio();
      _isBackgroundCapture = false;

      var mergedTranscript = baseTranscript;
      if (audioPath != null) {
        try {
          mergedTranscript = await _mergeOfflineAudio(
            audioPath,
            baseTranscript,
          );
        } finally {
          await _deleteAudioFile(audioPath);
        }
      }

      await _awaitMicRelease();
      await _recordingNotificationService.update(
        title: _notificationTitle,
        body: _notificationBody,
      );
      await _startListeningSession();
      emit(
        RecordingInProgress(
          transcript: mergedTranscript,
          selectedTemplate: _selectedTemplate,
        ),
      );
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
        isAiCapture: _captureForAi,
      ),
      VoiceCaptureTranscribingBackground() =>
        VoiceCaptureTranscribingBackground(
          transcript: transcript,
          selectedTemplate: _selectedTemplate,
        ),
      VoiceCaptureAiTranscribing(
        :final sessionId,
        :final startedAt,
        :final estimatedDuration,
      ) =>
        VoiceCaptureAiTranscribing(
          transcript: transcript,
          sessionId: sessionId,
          startedAt: startedAt,
          estimatedDuration: estimatedDuration,
          selectedTemplate: _selectedTemplate,
        ),
      ListeningPaused() => ListeningPaused(
        transcript: transcript,
        selectedTemplate: _selectedTemplate,
        isAiCapture: _captureForAi,
      ),
      VoiceCaptureFailure(:final message, :final errorCode) =>
        VoiceCaptureFailure(
          message,
          errorCode: errorCode,
          transcript: transcript,
          selectedTemplate: _selectedTemplate,
        ),
      VoiceCaptureEnhancing(
        :final phase,
        :final recordingDuration,
        :final userScratchNotes,
        :final isAiCapture,
      ) =>
        VoiceCaptureEnhancing(
          transcript: transcript,
          phase: phase,
          recordingDuration: recordingDuration,
          userScratchNotes: userScratchNotes,
          isAiCapture: isAiCapture,
        ),
      VoiceCaptureTranscriptCompare(:final aiTranscript) =>
        VoiceCaptureTranscriptCompare(
          localTranscript: transcript,
          aiTranscript: aiTranscript,
          selectedTemplate: _selectedTemplate,
        ),
      VoiceCaptureProcessing() => VoiceCaptureProcessing(
        transcript: transcript,
      ),
      _ => VoiceCaptureReady(
        transcript: transcript,
        selectedTemplate: _selectedTemplate,
      ),
    };
  }

  void _onScratchNotesUpdated(
    VoiceCaptureScratchNotesUpdated event,
    Emitter<VoiceCaptureState> emit,
  ) {
    _userScratchNotes = event.notes;
    final current = state;
    if (current is VoiceCaptureEnhancing) {
      emit(
        VoiceCaptureEnhancing(
          transcript: current.transcript,
          phase: current.phase,
          recordingDuration: current.recordingDuration,
          userScratchNotes: _userScratchNotes,
          isAiCapture: current.isAiCapture,
        ),
      );
    }
  }

  Future<void> _onAiChunkTick(
    VoiceCaptureAiChunkTick event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    if (!_captureForAi || _isDiscarding || state is! RecordingInProgress) {
      return;
    }
    final sessionId = _activeSession?.id;
    if (sessionId == null || !_backgroundAudioRecorder.isRecording) {
      return;
    }
    try {
      final chunkPath = await _backgroundAudioRecorder.rotateChunk(
        sessionId: sessionId,
      );
      if (chunkPath == null) {
        return;
      }
      final index = _nextChunkIndex++;
      _enqueueChunkTranscription(
        filePath: chunkPath,
        sessionId: sessionId,
        chunkIndex: index,
        isFinal: false,
        language: _pendingFinishLanguage,
      );
    } catch (_) {
      // Keep recording; finish path will flush remaining audio.
    }
  }

  void _startAiChunkTimer() {
    _stopAiChunkTimer();
    _aiChunkTimer = Timer.periodic(_aiChunkInterval, (_) {
      if (!isClosed) {
        add(const VoiceCaptureAiChunkTick());
      }
    });
  }

  void _stopAiChunkTimer() {
    _aiChunkTimer?.cancel();
    _aiChunkTimer = null;
  }

  void _resetAiChunkState() {
    _stopAiChunkTimer();
    _nextChunkIndex = 0;
    _inflightChunkFutures.clear();
    _completedChunkTexts.clear();
    _userScratchNotes = '';
    _recordingDuration = Duration.zero;
  }

  void _enqueueChunkTranscription({
    required String filePath,
    required String sessionId,
    required int chunkIndex,
    required bool isFinal,
    required String language,
  }) {
    final future = () async {
      try {
        final text = await _enhancedTranscriptionRepository.transcribeFile(
          filePath: filePath,
          sessionId: sessionId,
          language: language,
          chunkIndex: chunkIndex,
          isFinal: isFinal,
        );
        final anonymized = AnonymizationHelper.anonymize(text);
        if (anonymized.trim().isNotEmpty) {
          _completedChunkTexts[chunkIndex] = anonymized.trim();
        }
        return anonymized;
      } catch (_) {
        return null;
      } finally {
        await _deleteAudioFile(filePath);
      }
    }();
    _inflightChunkFutures[chunkIndex] = future;
  }

  Future<String> _awaitStitchedAiTranscript() async {
    if (_inflightChunkFutures.isNotEmpty) {
      await Future.wait(_inflightChunkFutures.values);
    }
    final indices = _completedChunkTexts.keys.toList()..sort();
    final parts = <String>[];
    for (final index in indices) {
      final text = _completedChunkTexts[index]?.trim() ?? '';
      if (text.isNotEmpty) {
        parts.add(text);
      }
    }
    return parts.join(' ').trim();
  }

  String _mergeAiWithScratchNotes(String aiTranscript) {
    final notes = _userScratchNotes.trim();
    if (notes.isEmpty) {
      return aiTranscript;
    }
    if (aiTranscript.trim().isEmpty) {
      return notes;
    }
    return '$aiTranscript\n\n--- Notes ---\n$notes';
  }

  Future<void> _finishAiProgressiveConsultation({
    required Emitter<VoiceCaptureState> emit,
    required String sessionId,
    required String language,
    required String roughTranscript,
    required Stopwatch uxStopwatch,
    required List<String> pendingAudioPaths,
  }) async {
    void emitPhase(TranscriptionWaitPhase phase) {
      emit(
        VoiceCaptureEnhancing(
          transcript: '',
          phase: phase,
          recordingDuration: _recordingDuration,
          userScratchNotes: _userScratchNotes,
          isAiCapture: true,
        ),
      );
    }

    emitPhase(TranscriptionWaitPhase.upload);

    // Flush the last in-progress WAV as a final chunk.
    final lastPath = await _stopSessionAudio();
    if (lastPath != null) {
      pendingAudioPaths.add(lastPath);
      final index = _nextChunkIndex++;
      try {
        final text = await _enhancedTranscriptionRepository.transcribeFile(
          filePath: lastPath,
          sessionId: sessionId,
          language: language,
          chunkIndex: index,
          isFinal: true,
        );
        final anonymized = AnonymizationHelper.anonymize(text).trim();
        if (anonymized.isNotEmpty) {
          _completedChunkTexts[index] = anonymized;
        }
      } catch (_) {
        // Offline Whisper fallback below if cloud produced nothing overall.
      }
    } else if (_completedChunkTexts.isEmpty && _inflightChunkFutures.isEmpty) {
      throw const AudioException(
        'Aucun fichier audio disponible pour la transcription.',
      );
    }

    emitPhase(TranscriptionWaitPhase.transcription);
    var stitched = await _awaitStitchedAiTranscript();

    // Fallback: offline Whisper on last file only if cloud produced nothing.
    // Keep it hidden from the UI (no compare panel in AI capture mode).
    if (stitched.isEmpty && lastPath != null) {
      try {
        final offlineText = await _offlineAudioTranscriptionService
            .transcribeFile(lastPath, language: language);
        if (offlineText.isNotEmpty) {
          stitched = AnonymizationHelper.anonymize(offlineText);
        }
      } catch (_) {}
    }

    if (stitched.trim().isEmpty) {
      throw const AudioException(
        'La transcription a échoué ou ne contient aucune parole. Veuillez réessayer.',
      );
    }

    emitPhase(TranscriptionWaitPhase.polish);
    final merged = _mergeAiWithScratchNotes(stitched);
    _resetAiChunkState();

    await _finalizeConsultation(
      emit: emit,
      sessionId: sessionId,
      transcriptForProcess: merged,
      language: language,
      transcriptIsAi: true,
      uxStopwatch: uxStopwatch,
    );
  }

  Future<void> _startListeningSession() async {
    if (_isDiscarding) return;
    final generation = _discardGeneration;
    if (_backgroundAudioRecorder.isRecording) {
      await _discardSessionAudio();
      await _awaitMicRelease();
    }
    if (_isDiscarding || generation != _discardGeneration) return;
    await _audioCaptureService.startListening(
      onResult: (text, {isFinal = false}) {
        if (isClosed ||
            _isBackgroundCapture ||
            _isDiscarding ||
            generation != _discardGeneration) {
          return;
        }
        add(VoiceCaptureTranscriptUpdated(text, isFinal: isFinal));
      },
      onListeningEnded: () {
        if (isClosed ||
            _isBackgroundCapture ||
            _isDiscarding ||
            generation != _discardGeneration) {
          return;
        }
        add(const VoiceCaptureListeningSessionEnded());
      },
    );
    if (_isDiscarding || generation != _discardGeneration) {
      await _audioCaptureService.stopListening();
    }
  }

  Future<void> _ensureSessionAudioStarted() async {
    if (_backgroundAudioRecorder.isRecording) {
      return;
    }
    if (_audioCaptureService.isListening) {
      await _audioCaptureService.stopListening();
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

  Future<void> _discardSessionAudio() async {
    if (!_backgroundAudioRecorder.isRecording) {
      return;
    }
    try {
      await _backgroundAudioRecorder.cancel();
    } catch (_) {}
  }

  Future<void> _awaitMicRelease() {
    return Future<void>.delayed(_micReleaseDelay);
  }

  Future<String> _mergeOfflineAudio(
    String audioPath,
    String baseTranscript,
  ) async {
    final offlineText = await _offlineAudioTranscriptionService.transcribeFile(
      audioPath,
      language: 'fr',
    );
    if (offlineText.isEmpty) {
      return baseTranscript;
    }

    final anonymized = AnonymizationHelper.anonymize(offlineText);
    final punctuated = PunctuationHelper.applyHeuristics(
      text: anonymized,
      wordPeriod: _wordPeriod,
      wordComma: _wordComma,
      transitionWords: _transitions,
    );
    final merged = TranscriptMergeHelper.merge(baseTranscript, punctuated);
    final corrected = await _medicalTermCorrectionService.correct(merged);
    _segmentBase = corrected;
    await _saveActiveSessionTranscript(corrected);
    return corrected;
  }

  Future<void> _stopListeningAndNotification() async {
    await _audioCaptureService.stopListening();
    _isBackgroundCapture = false;
    await _recordingNotificationService.stop();
  }

  Future<void> _stopRecordingInfrastructure() async {
    _stopAiChunkTimer();
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
      VoiceCaptureAiTranscribing(:final transcript) => transcript,
      ListeningPaused(:final transcript) => transcript,
      VoiceCaptureFailure(:final transcript) => transcript,
      VoiceCaptureProcessing(:final transcript) => transcript,
      VoiceCaptureEnhancing(:final transcript) => transcript,
      VoiceCaptureTranscriptCompare(:final localTranscript) => localTranscript,
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
    final template = _selectedTemplate;
    final pathologies = template == null
        ? const <SessionPathology>[]
        : [
            SessionPathology(
              id: template.pathologyId ?? template.pathologyKey,
              name: template.name,
              templateId: template.id,
            ),
          ];
    final session = RecordingSession(
      id: _generateSessionId(startedAt),
      patientId: patientId,
      startedAt: startedAt,
      transcript: transcript,
      status: RecordingSessionStatus.recording,
      templateId: template?.id,
      templateName: template?.name,
      pathologies: pathologies,
    );
    _activeSession = await _recordingSessionRepository.save(session);
  }

  Future<void> _completeActiveSession({
    required String transcript,
    required SoapNote soapNote,
    bool transcriptIsAi = false,
  }) async {
    final session = _activeSession;
    if (session == null) {
      return;
    }

    final template = _selectedTemplate;
    final pathologies = template != null
        ? [
            SessionPathology(
              id: template.pathologyId ?? template.pathologyKey,
              name: template.name,
              templateId: template.id,
            ),
          ]
        : session.pathologies;

    final completed = session.copyWith(
      endedAt: DateTime.now(),
      transcript: transcript,
      transcriptIsAi: transcriptIsAi,
      soapNote: soapNote,
      status: RecordingSessionStatus.completed,
      templateId: template?.id ?? session.templateId,
      templateName: template?.name ?? session.templateName,
      pathologies: pathologies,
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

  void _updateActiveSessionTranscriptInMemory(
    String transcript, {
    bool? transcriptIsAi,
  }) {
    final session = _activeSession;
    if (session == null) {
      return;
    }

    _activeSession = session.copyWith(
      transcript: transcript,
      transcriptIsAi: transcriptIsAi,
    );
  }

  Future<void> _saveActiveSessionTranscript(
    String transcript, {
    bool? transcriptIsAi,
  }) async {
    final session = _activeSession;
    if (session == null) {
      return;
    }

    final updated = session.copyWith(
      transcript: transcript,
      transcriptIsAi: transcriptIsAi,
    );
    _activeSession = updated;
    await _recordingSessionRepository.save(updated);
  }

  @override
  Future<void> close() async {
    _resetAiChunkState();
    await _cancelJobSubscription();
    // Do not reset the AI job cubit — it outlives this page-scoped bloc.
    if (state is! VoiceCaptureAiTranscribing) {
      await _stopRecordingInfrastructure();
    }
    return super.close();
  }
}
