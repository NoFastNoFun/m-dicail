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
  const VoiceCaptureFinishConsultation({
    this.language = 'fr',
    this.isTutorial = false,
    this.recordingDuration = Duration.zero,
  });

  final String language;
  final bool isTutorial;
  final Duration recordingDuration;

  @override
  List<Object?> get props => [language, isTutorial, recordingDuration];
}

final class VoiceCaptureTranscriptChoiceSelected extends VoiceCaptureEvent {
  const VoiceCaptureTranscriptChoiceSelected({required this.useAi});

  final bool useAi;

  @override
  List<Object?> get props => [useAi];
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
  const VoiceCaptureTranscriptUpdated(this.rawText, {this.isFinal = false});

  final String rawText;
  final bool isFinal;

  @override
  List<Object?> get props => [rawText, isFinal];
}

final class VoiceCaptureTemplateSelected extends VoiceCaptureEvent {
  const VoiceCaptureTemplateSelected(this.template);

  final NoteTemplate? template;

  @override
  List<Object?> get props => [template];
}

final class VoiceCaptureAppBackgrounded extends VoiceCaptureEvent {
  const VoiceCaptureAppBackgrounded();
}

final class VoiceCaptureAppForegrounded extends VoiceCaptureEvent {
  const VoiceCaptureAppForegrounded();
}

/// Periodic tick while AI capture is recording: rotate + upload a chunk.
final class VoiceCaptureAiChunkTick extends VoiceCaptureEvent {
  const VoiceCaptureAiChunkTick();
}

/// User typed notes into the wait-time skeleton editor.
final class VoiceCaptureScratchNotesUpdated extends VoiceCaptureEvent {
  const VoiceCaptureScratchNotesUpdated(this.notes);

  final String notes;

  @override
  List<Object?> get props => [notes];
}
