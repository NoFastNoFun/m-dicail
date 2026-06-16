import 'package:medicail/features/voice_capture/presentation/voice_capture_state.dart';

enum VoiceCaptureSessionStatus {
  initializing,
  ready,
  listening,
  paused,
  processing,
  ended,
  failure,
}

final class VoiceCaptureViewModel {
  const VoiceCaptureViewModel({
    required this.status,
    this.transcript = '',
    this.errorMessage,
  });

  factory VoiceCaptureViewModel.fromState(VoiceCaptureState state) {
    return switch (state) {
      VoiceCaptureInitial() => const VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.initializing,
        ),
      VoiceCaptureReady(:final transcript) => VoiceCaptureViewModel(
          status: transcript.trim().isEmpty
              ? VoiceCaptureSessionStatus.ready
              : VoiceCaptureSessionStatus.ended,
          transcript: transcript,
        ),
      VoiceCaptureConsultationFinished(:final transcript) => VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.ended,
          transcript: transcript,
        ),
      VoiceCaptureProcessing(:final transcript) => VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.processing,
          transcript: transcript,
        ),
      RecordingInProgress(:final transcript) => VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.listening,
          transcript: transcript,
        ),
      ListeningPaused(:final transcript) => VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.paused,
          transcript: transcript,
        ),
      VoiceCaptureFailure(:final message, :final transcript) =>
        VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.failure,
          transcript: transcript,
          errorMessage: message,
        ),
    };
  }

  final VoiceCaptureSessionStatus status;
  final String transcript;
  final String? errorMessage;

  bool get isInitializing =>
      status == VoiceCaptureSessionStatus.initializing ||
      status == VoiceCaptureSessionStatus.processing;

  bool get isListening => status == VoiceCaptureSessionStatus.listening;

  bool get isConsultationOpen =>
      status == VoiceCaptureSessionStatus.listening ||
      status == VoiceCaptureSessionStatus.paused;

  bool get hasTranscript => transcript.trim().isNotEmpty;

  bool get canStart =>
      status == VoiceCaptureSessionStatus.ready ||
      status == VoiceCaptureSessionStatus.paused;

  bool get canStop => isListening;

  bool get canFinishConsultation => isConsultationOpen;

  bool get canClear => !isConsultationOpen && hasTranscript;
}
