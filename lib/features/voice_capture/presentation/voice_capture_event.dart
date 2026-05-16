import 'package:equatable/equatable.dart';

sealed class VoiceCaptureEvent extends Equatable {
  const VoiceCaptureEvent();

  @override
  List<Object?> get props => [];
}

final class VoiceCaptureInitializeRequested extends VoiceCaptureEvent {
  const VoiceCaptureInitializeRequested();
}

final class VoiceCaptureStartRecording extends VoiceCaptureEvent {
  const VoiceCaptureStartRecording();
}

final class VoiceCaptureStopRecording extends VoiceCaptureEvent {
  const VoiceCaptureStopRecording();
}

final class VoiceCaptureListeningSessionEnded extends VoiceCaptureEvent {
  const VoiceCaptureListeningSessionEnded();
}

final class VoiceCaptureTranscriptUpdated extends VoiceCaptureEvent {
  const VoiceCaptureTranscriptUpdated(this.rawText);

  final String rawText;

  @override
  List<Object?> get props => [rawText];
}
