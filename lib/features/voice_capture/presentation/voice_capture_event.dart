import 'package:equatable/equatable.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';

sealed class VoiceCaptureEvent extends Equatable {
  const VoiceCaptureEvent();

  @override
  List<Object?> get props => [];
}

final class VoiceCaptureInitializeRequested extends VoiceCaptureEvent {
  const VoiceCaptureInitializeRequested();
}

final class VoiceCaptureStartRecording extends VoiceCaptureEvent {
  const VoiceCaptureStartRecording({this.patientId});

  final String? patientId;

  @override
  List<Object?> get props => [patientId];
}

final class VoiceCaptureStopRecording extends VoiceCaptureEvent {
  const VoiceCaptureStopRecording();
}

final class VoiceCaptureFinishConsultation extends VoiceCaptureEvent {
  const VoiceCaptureFinishConsultation();
}

final class VoiceCaptureClearTranscript extends VoiceCaptureEvent {
  const VoiceCaptureClearTranscript();
}

final class VoiceCaptureDiscardConsultation extends VoiceCaptureEvent {
  const VoiceCaptureDiscardConsultation();
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

final class VoiceCaptureTemplateSelected extends VoiceCaptureEvent {
  const VoiceCaptureTemplateSelected(this.template);

  final NoteTemplate? template;

  @override
  List<Object?> get props => [template];
}
