import 'package:equatable/equatable.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';

sealed class AiTranscriptionJobState extends Equatable {
  const AiTranscriptionJobState();

  @override
  List<Object?> get props => [];
}

final class AiTranscriptionJobIdle extends AiTranscriptionJobState {
  const AiTranscriptionJobIdle();
}

final class AiTranscriptionJobRunning extends AiTranscriptionJobState {
  const AiTranscriptionJobRunning({
    required this.sessionId,
    required this.language,
    required this.roughTranscript,
    required this.startedAt,
    required this.estimatedDuration,
    required this.audioDuration,
    this.patientId,
    this.selectedTemplate,
  });

  final String sessionId;
  final String? patientId;
  final String language;
  final String roughTranscript;
  final NoteTemplate? selectedTemplate;
  final DateTime startedAt;
  final Duration estimatedDuration;
  final Duration audioDuration;

  Duration get remainingEstimate {
    final elapsed = DateTime.now().difference(startedAt);
    final remaining = estimatedDuration - elapsed;
    if (remaining <= Duration.zero) {
      return Duration.zero;
    }
    return remaining;
  }

  bool get estimateElapsed => remainingEstimate <= Duration.zero;

  @override
  List<Object?> get props => [
        sessionId,
        patientId,
        language,
        roughTranscript,
        selectedTemplate,
        startedAt,
        estimatedDuration,
        audioDuration,
      ];
}

final class AiTranscriptionJobReady extends AiTranscriptionJobState {
  const AiTranscriptionJobReady({
    required this.sessionId,
    required this.language,
    required this.localTranscript,
    required this.aiTranscript,
    this.patientId,
    this.selectedTemplate,
  });

  final String sessionId;
  final String? patientId;
  final String language;
  final String localTranscript;
  final String aiTranscript;
  final NoteTemplate? selectedTemplate;

  @override
  List<Object?> get props => [
        sessionId,
        patientId,
        language,
        localTranscript,
        aiTranscript,
        selectedTemplate,
      ];
}

/// Cloud failed or was empty; local transcript is ready for SOAP without compare.
final class AiTranscriptionJobCompletedWithoutCompare
    extends AiTranscriptionJobState {
  const AiTranscriptionJobCompletedWithoutCompare({
    required this.sessionId,
    required this.language,
    required this.transcript,
    this.patientId,
    this.selectedTemplate,
  });

  final String sessionId;
  final String? patientId;
  final String language;
  final String transcript;
  final NoteTemplate? selectedTemplate;

  @override
  List<Object?> get props => [
        sessionId,
        patientId,
        language,
        transcript,
        selectedTemplate,
      ];
}

final class AiTranscriptionJobFailed extends AiTranscriptionJobState {
  const AiTranscriptionJobFailed({
    required this.sessionId,
    required this.message,
    required this.roughTranscript,
    this.patientId,
    this.selectedTemplate,
  });

  final String sessionId;
  final String? patientId;
  final String message;
  final String roughTranscript;
  final NoteTemplate? selectedTemplate;

  @override
  List<Object?> get props => [
        sessionId,
        patientId,
        message,
        roughTranscript,
        selectedTemplate,
      ];
}
