import 'package:medicail/features/recording/domain/entities/soap_note.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_state.dart';

enum VoiceCaptureSessionStatus {
  initializing,
  ready,
  listening,
  paused,
  ended,
  failure,
}

final class VoiceCaptureViewModel {
  const VoiceCaptureViewModel({
    required this.status,
    this.transcript = '',
    this.errorMessage,
    this.activeSessionId,
    this.activeSoapNote,
  });

  factory VoiceCaptureViewModel.fromState(VoiceCaptureState state) {
    return switch (state) {
      VoiceCaptureInitial() => const VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.initializing,
        ),
      VoiceCaptureReady(
        :final transcript,
        :final activeSessionId,
        :final activeSoapNote,
      ) =>
        VoiceCaptureViewModel(
          status: transcript.trim().isEmpty
              ? VoiceCaptureSessionStatus.ready
              : VoiceCaptureSessionStatus.ended,
          transcript: transcript,
          activeSessionId: activeSessionId,
          activeSoapNote: activeSoapNote,
        ),
      VoiceCaptureConsultationFinished(:final transcript) => VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.ended,
          transcript: transcript,
        ),
      RecordingInProgress(
        :final transcript,
        :final activeSessionId,
        :final activeSoapNote,
      ) =>
        VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.listening,
          transcript: transcript,
          activeSessionId: activeSessionId,
          activeSoapNote: activeSoapNote,
        ),
      ListeningPaused(
        :final transcript,
        :final activeSessionId,
        :final activeSoapNote,
      ) =>
        VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.paused,
          transcript: transcript,
          activeSessionId: activeSessionId,
          activeSoapNote: activeSoapNote,
        ),
      VoiceCaptureFailure(
        :final message,
        :final transcript,
        :final activeSessionId,
        :final activeSoapNote,
      ) =>
        VoiceCaptureViewModel(
          status: VoiceCaptureSessionStatus.failure,
          transcript: transcript,
          errorMessage: message,
          activeSessionId: activeSessionId,
          activeSoapNote: activeSoapNote,
        ),
    };
  }

  final VoiceCaptureSessionStatus status;
  final String transcript;
  final String? errorMessage;
  final String? activeSessionId;
  final SoapNote? activeSoapNote;

  bool get isInitializing => status == VoiceCaptureSessionStatus.initializing;

  bool get isListening => status == VoiceCaptureSessionStatus.listening;

  bool get isConsultationOpen =>
      status == VoiceCaptureSessionStatus.listening ||
      status == VoiceCaptureSessionStatus.paused;

  bool get hasTranscript => transcript.trim().isNotEmpty;

  bool get hasActiveSession => activeSessionId != null;

  bool get canStart =>
      status == VoiceCaptureSessionStatus.ready ||
      status == VoiceCaptureSessionStatus.paused;

  bool get canStop => isListening;

  bool get canFinishConsultation => isConsultationOpen;

  bool get canClear => !isConsultationOpen && hasTranscript;
}
