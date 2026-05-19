import 'package:medicail/features/voice_capture/presentation/voice_capture_state.dart';

enum VoiceCaptureSessionStatus {
  initializing,
  ready,
  listening,
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
      RecordingInProgress(:final transcript) => VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.listening,
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

  bool get isInitializing => status == VoiceCaptureSessionStatus.initializing;

  bool get isListening => status == VoiceCaptureSessionStatus.listening;

  bool get hasTranscript => transcript.trim().isNotEmpty;

  bool get canStart =>
      status == VoiceCaptureSessionStatus.ready ||
      status == VoiceCaptureSessionStatus.ended;

  bool get canStop => isListening;

  bool get canClear => !isListening && hasTranscript;
}
