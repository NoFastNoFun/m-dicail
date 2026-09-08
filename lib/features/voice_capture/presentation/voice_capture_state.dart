import 'package:equatable/equatable.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';

sealed class VoiceCaptureState extends Equatable {
  const VoiceCaptureState();

  @override
  List<Object?> get props => [];
}

final class VoiceCaptureInitial extends VoiceCaptureState {
  const VoiceCaptureInitial();
}

final class VoiceCaptureReady extends VoiceCaptureState {
  const VoiceCaptureReady({this.transcript = '', this.selectedTemplate});

  final String transcript;
  final NoteTemplate? selectedTemplate;

  @override
  List<Object?> get props => [transcript, selectedTemplate];
}

final class VoiceCaptureConsultationFinished extends VoiceCaptureState {
  const VoiceCaptureConsultationFinished({
    required this.sessionId,
    this.transcript = '',
  });

  final String sessionId;
  final String transcript;

  @override
  List<Object?> get props => [sessionId, transcript];
}

final class VoiceCaptureProcessing extends VoiceCaptureState {
  const VoiceCaptureProcessing({required this.transcript});

  final String transcript;

  @override
  List<Object?> get props => [transcript];
}

final class VoiceCaptureEnhancing extends VoiceCaptureState {
  const VoiceCaptureEnhancing({required this.transcript});

  final String transcript;

  @override
  List<Object?> get props => [transcript];
}

final class VoiceCaptureTranscriptCompare extends VoiceCaptureState {
  const VoiceCaptureTranscriptCompare({
    required this.localTranscript,
    required this.aiTranscript,
    this.selectedTemplate,
  });

  final String localTranscript;
  final String aiTranscript;
  final NoteTemplate? selectedTemplate;

  @override
  List<Object?> get props => [localTranscript, aiTranscript, selectedTemplate];
}

final class RecordingInProgress extends VoiceCaptureState {
  const RecordingInProgress({
    required this.transcript,
    this.selectedTemplate,
    this.isBackgroundCapture = false,
    this.isAiCapture = false,
  });

  final String transcript;
  final NoteTemplate? selectedTemplate;
  final bool isBackgroundCapture;
  final bool isAiCapture;

  @override
  List<Object?> get props => [
    transcript,
    selectedTemplate,
    isBackgroundCapture,
    isAiCapture,
  ];
}

final class VoiceCaptureTranscribingBackground extends VoiceCaptureState {
  const VoiceCaptureTranscribingBackground({
    required this.transcript,
    this.selectedTemplate,
  });

  final String transcript;
  final NoteTemplate? selectedTemplate;

  @override
  List<Object?> get props => [transcript, selectedTemplate];
}

final class ListeningPaused extends VoiceCaptureState {
  const ListeningPaused({
    required this.transcript,
    this.selectedTemplate,
    this.isAiCapture = false,
  });

  final String transcript;
  final NoteTemplate? selectedTemplate;
  final bool isAiCapture;

  @override
  List<Object?> get props => [transcript, selectedTemplate, isAiCapture];
}

final class VoiceCaptureFailure extends VoiceCaptureState {
  const VoiceCaptureFailure(
    this.message, {
    this.transcript = '',
    this.selectedTemplate,
  });

  final String message;
  final String transcript;
  final NoteTemplate? selectedTemplate;

  @override
  List<Object?> get props => [message, transcript, selectedTemplate];
}
