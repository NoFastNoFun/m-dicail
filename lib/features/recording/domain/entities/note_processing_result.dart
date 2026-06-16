import 'package:equatable/equatable.dart';

class NoteProcessingResult extends Equatable {
  const NoteProcessingResult({
    required this.sessionId,
    required this.anonymizedText,
    required this.aiResponse,
  });

  final String sessionId;
  final String anonymizedText;
  final NoteAiResponse aiResponse;

  factory NoteProcessingResult.fromJson(Map<String, dynamic> json) {
    return NoteProcessingResult(
      sessionId: json['session_id'] as String? ?? '',
      anonymizedText: json['anonymized_text'] as String? ?? '',
      aiResponse: NoteAiResponse.fromJson(
        json['ai_response'] as Map<String, dynamic>? ??
            const <String, dynamic>{},
      ),
    );
  }

  @override
  List<Object?> get props => [sessionId, anonymizedText, aiResponse];
}

class NoteAiResponse extends Equatable {
  const NoteAiResponse({
    this.summary = '',
    this.recommendations = const [],
    this.exercises = const [],
    this.evidenceLevel = '',
    this.sources = const [],
    this.precautions = const [],
  });

  final String summary;
  final List<String> recommendations;
  final List<String> exercises;
  final String evidenceLevel;
  final List<String> sources;
  final List<String> precautions;

  factory NoteAiResponse.fromJson(Map<String, dynamic> json) {
    return NoteAiResponse(
      summary: json['summary'] as String? ?? '',
      recommendations: _stringList(json['recommendations']),
      exercises: _stringList(json['exercises']),
      evidenceLevel: json['evidence_level'] as String? ?? '',
      sources: _stringList(json['sources']),
      precautions: _stringList(json['precautions']),
    );
  }

  bool get isEmpty =>
      summary.trim().isEmpty &&
      recommendations.isEmpty &&
      exercises.isEmpty &&
      evidenceLevel.trim().isEmpty &&
      sources.isEmpty &&
      precautions.isEmpty;

  static List<String> _stringList(Object? value) {
    if (value is! List) {
      return const [];
    }
    return value.whereType<String>().toList(growable: false);
  }

  @override
  List<Object?> get props => [
        summary,
        recommendations,
        exercises,
        evidenceLevel,
        sources,
        precautions,
      ];
}
