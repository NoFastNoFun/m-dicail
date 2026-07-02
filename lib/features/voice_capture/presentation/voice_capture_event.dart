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
  const VoiceCaptureStartRecording({
    this.patientId,
    this.transitions = const [],
    this.wordPeriod = '',
    this.wordComma = '',
  });

  final String? patientId;
  final List<String> transitions;
  final String wordPeriod;
  final String wordComma;

  @override
  List<Object?> get props => [patientId, transitions, wordPeriod, wordComma];
}

final class VoiceCaptureStopRecording extends VoiceCaptureEvent {
  const VoiceCaptureStopRecording();
}

final class VoiceCaptureFinishConsultation extends VoiceCaptureEvent {
  const VoiceCaptureFinishConsultation({this.language = 'fr'});

  final String language;

  @override
  List<Object?> get props => [language];
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
