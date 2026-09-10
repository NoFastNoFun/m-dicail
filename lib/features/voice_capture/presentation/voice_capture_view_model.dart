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
          transcript: transcript,
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
      ListeningPaused(
        :final transcript,
        :final selectedTemplate,
        :final isAiCapture,
      ) =>
        VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.paused,
          isAiCapture: isAiCapture,
          transcript: transcript,
          selectedTemplate: selectedTemplate,
        ),
      VoiceCaptureProcessing(:final transcript) => VoiceCaptureViewModel(
        status: VoiceCaptureSessionStatus.processing,
        transcript: transcript,
      ),
      VoiceCaptureEnhancing(:final transcript) => VoiceCaptureViewModel(
        status: VoiceCaptureSessionStatus.enhancing,
        transcript: transcript,
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
      !isComparingTranscripts;

  bool get canStop => isListening && !isProcessing && !isComparingTranscripts;

  bool get canFinishConsultation =>
      isConsultationOpen && !isProcessing && !isComparingTranscripts;

  bool get canClear =>
      !isConsultationOpen &&
      hasTranscript &&
      !isProcessing &&
      !isComparingTranscripts;

  bool get isProcessing =>
      status == VoiceCaptureSessionStatus.processing ||
      status == VoiceCaptureSessionStatus.enhancing ||
      status == VoiceCaptureSessionStatus.transcribingBackground;

  bool get isEnhancing => status == VoiceCaptureSessionStatus.enhancing;

  bool get isComparingTranscripts =>
      status == VoiceCaptureSessionStatus.comparingTranscripts;

  bool get isTranscribingBackground =>
      status == VoiceCaptureSessionStatus.transcribingBackground;

  bool get hasUnsavedWork =>
      isConsultationOpen ||
      isComparingTranscripts ||
      (hasTranscript &&
          status != VoiceCaptureSessionStatus.initializing &&
          status != VoiceCaptureSessionStatus.completed);
}
