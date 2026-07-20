import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_state.dart';

enum VoiceCaptureSessionStatus {
  initializing,
  ready,
  listening,
  paused,
  ended,
  processing,
  failure,
}

final class VoiceCaptureViewModel {
  const VoiceCaptureViewModel({
    required this.status,
    this.transcript = '',
    this.errorMessage,
    this.selectedTemplate,
  });

  factory VoiceCaptureViewModel.fromState(VoiceCaptureState state) {
    return switch (state) {
      VoiceCaptureInitial() => const VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.initializing,
        ),
      VoiceCaptureReady(
        :final transcript,
        :final selectedTemplate,
      ) =>
        VoiceCaptureViewModel(
          status: transcript.trim().isEmpty
              ? VoiceCaptureSessionStatus.ready
              : VoiceCaptureSessionStatus.ended,
          transcript: transcript,
          selectedTemplate: selectedTemplate,
        ),
      VoiceCaptureConsultationFinished(:final transcript) => VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.ended,
          transcript: transcript,
        ),
      RecordingInProgress(
        :final transcript,
        :final selectedTemplate,
      ) =>
        VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.listening,
          transcript: transcript,
          selectedTemplate: selectedTemplate,
        ),
      ListeningPaused(
        :final transcript,
        :final selectedTemplate,
      ) =>
        VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.paused,
          transcript: transcript,
          selectedTemplate: selectedTemplate,
        ),
      VoiceCaptureProcessing(:final transcript) => VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.processing,
          transcript: transcript,
        ),
      VoiceCaptureFailure(
        :final message,
        :final transcript,
        :final selectedTemplate,
      ) =>
        VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.failure,
          transcript: transcript,
          errorMessage: message,
          selectedTemplate: selectedTemplate,
        ),
    };
  }

  final VoiceCaptureSessionStatus status;
  final String transcript;
  final String? errorMessage;
  final NoteTemplate? selectedTemplate;

  bool get isInitializing => status == VoiceCaptureSessionStatus.initializing;

  bool get isListening => status == VoiceCaptureSessionStatus.listening;

  bool get isConsultationOpen =>
      status == VoiceCaptureSessionStatus.listening ||
      status == VoiceCaptureSessionStatus.paused;

  bool get hasTranscript => transcript.trim().isNotEmpty;

  bool get canStart =>
      (status == VoiceCaptureSessionStatus.ready ||
      status == VoiceCaptureSessionStatus.paused) && !isProcessing;

  bool get canStop => isListening && !isProcessing;

  bool get canFinishConsultation => isConsultationOpen && !isProcessing;

  bool get canClear => !isConsultationOpen && hasTranscript && !isProcessing;

  bool get isProcessing => status == VoiceCaptureSessionStatus.processing;

  bool get hasUnsavedWork =>
      isConsultationOpen ||
      (hasTranscript && status != VoiceCaptureSessionStatus.initializing);
}
