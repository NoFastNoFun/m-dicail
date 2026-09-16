import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_state.dart';

enum VoiceCaptureSessionStatus {
  initializing,
  ready,
  listening,
  paused,
  ended,
  completed,
  processing,
  enhancing,
  comparingTranscripts,
  transcribingBackground,
  aiTranscribing,
  failure,
}

final class VoiceCaptureViewModel {
  const VoiceCaptureViewModel({
    required this.status,
    this.transcript = '',
    this.localTranscript = '',
    this.aiTranscript = '',
    this.isAiCapture = false,
    this.errorMessage,
    this.errorCode,
    this.selectedTemplate,
    this.waitPhase = TranscriptionWaitPhase.upload,
    this.recordingDuration = Duration.zero,
    this.userScratchNotes = '',
    this.aiTranscribingSessionId,
    this.aiTranscribingStartedAt,
    this.aiTranscribingEstimatedDuration,
  });

  factory VoiceCaptureViewModel.fromState(VoiceCaptureState state) {
    return switch (state) {
      VoiceCaptureInitial() => const VoiceCaptureViewModel(
        status: VoiceCaptureSessionStatus.initializing,
      ),
      VoiceCaptureReady(:final transcript, :final selectedTemplate) =>
        VoiceCaptureViewModel(
          status: transcript.trim().isEmpty
              ? VoiceCaptureSessionStatus.ready
              : VoiceCaptureSessionStatus.ended,
          transcript: transcript,
          selectedTemplate: selectedTemplate,
        ),
      VoiceCaptureConsultationFinished(:final transcript) =>
        VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.completed,
          transcript: transcript,
        ),
      RecordingInProgress(
        :final transcript,
        :final selectedTemplate,
        :final isAiCapture,
      ) =>
        VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.listening,
          isAiCapture: isAiCapture,
          // Hide local / progressive drafts while AI capture is on.
          transcript: isAiCapture ? '' : transcript,
          selectedTemplate: selectedTemplate,
        ),
      VoiceCaptureTranscribingBackground(
        :final transcript,
        :final selectedTemplate,
      ) =>
        VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.transcribingBackground,
          transcript: transcript,
          selectedTemplate: selectedTemplate,
        ),
      VoiceCaptureAiTranscribing(
        :final transcript,
        :final sessionId,
        :final startedAt,
        :final estimatedDuration,
        :final selectedTemplate,
      ) =>
        VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.aiTranscribing,
          transcript: transcript,
          selectedTemplate: selectedTemplate,
          aiTranscribingSessionId: sessionId,
          aiTranscribingStartedAt: startedAt,
          aiTranscribingEstimatedDuration: estimatedDuration,
        ),
      ListeningPaused(
        :final transcript,
        :final selectedTemplate,
        :final isAiCapture,
      ) =>
        VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.paused,
          isAiCapture: isAiCapture,
          transcript: isAiCapture ? '' : transcript,
          selectedTemplate: selectedTemplate,
        ),
      VoiceCaptureProcessing(:final transcript) => VoiceCaptureViewModel(
        status: VoiceCaptureSessionStatus.processing,
        transcript: transcript,
      ),
      VoiceCaptureEnhancing(
        :final transcript,
        :final phase,
        :final recordingDuration,
        :final userScratchNotes,
        :final isAiCapture,
      ) =>
        VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.enhancing,
          // Hide local Whisper drafts during AI wait; skeleton holds user notes.
          transcript: isAiCapture ? '' : transcript,
          isAiCapture: isAiCapture,
          waitPhase: phase,
          recordingDuration: recordingDuration,
          userScratchNotes: userScratchNotes,
        ),
      VoiceCaptureTranscriptCompare(
        :final localTranscript,
        :final aiTranscript,
        :final selectedTemplate,
      ) =>
        VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.comparingTranscripts,
          transcript: localTranscript,
          localTranscript: localTranscript,
          aiTranscript: aiTranscript,
          selectedTemplate: selectedTemplate,
        ),
      VoiceCaptureFailure(
        :final message,
        :final errorCode,
        :final transcript,
        :final selectedTemplate,
      ) =>
        VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.failure,
          transcript: transcript,
          errorMessage: message,
          errorCode: errorCode,
          selectedTemplate: selectedTemplate,
        ),
    };
  }

  final VoiceCaptureSessionStatus status;
  final String transcript;
  final String localTranscript;
  final String aiTranscript;
  final bool isAiCapture;
  final String? errorMessage;
  final VoiceCaptureErrorCode? errorCode;
  final NoteTemplate? selectedTemplate;
  final TranscriptionWaitPhase waitPhase;
  final Duration recordingDuration;
  final String userScratchNotes;
  final String? aiTranscribingSessionId;
  final DateTime? aiTranscribingStartedAt;
  final Duration? aiTranscribingEstimatedDuration;

  String? localizedErrorMessage(AppLocalizations l10n) => switch (errorCode) {
    VoiceCaptureErrorCode.invalidSoapNote => l10n.recordErrorInvalidSoapNote,
    null => errorMessage,
  };

  bool get isInitializing => status == VoiceCaptureSessionStatus.initializing;

  bool get isListening => status == VoiceCaptureSessionStatus.listening;

  bool get isConsultationOpen =>
      status == VoiceCaptureSessionStatus.listening ||
      status == VoiceCaptureSessionStatus.paused ||
      status == VoiceCaptureSessionStatus.transcribingBackground;

  bool get hasTranscript => transcript.trim().isNotEmpty;

  bool get canStart =>
      (status == VoiceCaptureSessionStatus.ready ||
          status == VoiceCaptureSessionStatus.paused) &&
      !isProcessing &&
      !isComparingTranscripts &&
      !isAiTranscribing;

  bool get canStop =>
      isListening &&
      !isProcessing &&
      !isComparingTranscripts &&
      !isAiTranscribing;

  bool get canFinishConsultation =>
      isConsultationOpen &&
      !isProcessing &&
      !isComparingTranscripts &&
      !isAiTranscribing;

  bool get canClear =>
      !isConsultationOpen &&
      hasTranscript &&
      !isProcessing &&
      !isComparingTranscripts &&
      !isAiTranscribing;

  bool get isProcessing =>
      status == VoiceCaptureSessionStatus.processing ||
      status == VoiceCaptureSessionStatus.enhancing ||
      status == VoiceCaptureSessionStatus.transcribingBackground;

  bool get isEnhancing => status == VoiceCaptureSessionStatus.enhancing;

  bool get isAiProgressiveWait => isEnhancing && isAiCapture;

  bool get isComparingTranscripts =>
      status == VoiceCaptureSessionStatus.comparingTranscripts;

  bool get isTranscribingBackground =>
      status == VoiceCaptureSessionStatus.transcribingBackground;

  bool get isAiTranscribing =>
      status == VoiceCaptureSessionStatus.aiTranscribing;

  bool get hasUnsavedWork =>
      isConsultationOpen ||
      isComparingTranscripts ||
      isAiProgressiveWait ||
      isAiTranscribing ||
      (hasTranscript &&
          status != VoiceCaptureSessionStatus.initializing &&
          status != VoiceCaptureSessionStatus.completed);

  /// Leave without discard dialog; background job continues.
  bool get canLeaveWhileAiTranscribing => isAiTranscribing;
}
