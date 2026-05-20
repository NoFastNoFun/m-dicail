import 'package:equatable/equatable.dart';

class SoapNote extends Equatable {
  const SoapNote({
    this.subjective = '',
    this.objective = '',
    this.assessment = '',
    this.plan = '',
  });

  final String subjective;
  final String objective;
  final String assessment;
  final String plan;

  SoapNote copyWith({
    String? subjective,
    String? objective,
    String? assessment,
    String? plan,
  }) {
    return SoapNote(
      subjective: subjective ?? this.subjective,
      objective: objective ?? this.objective,
      assessment: assessment ?? this.assessment,
      plan: plan ?? this.plan,
    );
  }

  factory SoapNote.fromJson(Map<String, dynamic> json) {
    return SoapNote(
      subjective: json['subjective'] as String? ?? '',
      objective: json['objective'] as String? ?? '',
      assessment: json['assessment'] as String? ?? '',
      plan: json['plan'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjective': subjective,
      'objective': objective,
      'assessment': assessment,
      'plan': plan,
    };
  }

  bool get isEmpty =>
      subjective.trim().isEmpty &&
      objective.trim().isEmpty &&
      assessment.trim().isEmpty &&
      plan.trim().isEmpty;

  @override
  List<Object?> get props => [
        subjective,
        objective,
        assessment,
        plan,
      ];
}
