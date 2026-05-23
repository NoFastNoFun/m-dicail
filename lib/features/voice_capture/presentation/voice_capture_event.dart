import 'package:equatable/equatable.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';

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

final class VoiceCaptureListeningSessionEnded extends VoiceCaptureEvent {
  const VoiceCaptureListeningSessionEnded();
}

final class VoiceCaptureTranscriptUpdated extends VoiceCaptureEvent {
  const VoiceCaptureTranscriptUpdated(this.rawText);

  final String rawText;

  @override
  List<Object?> get props => [rawText];
}

final class VoiceCaptureSoapNoteUpdated extends VoiceCaptureEvent {
  const VoiceCaptureSoapNoteUpdated(this.soapNote);

  final SoapNote soapNote;

  @override
  List<Object?> get props => [soapNote];
}
