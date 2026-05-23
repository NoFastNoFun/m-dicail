import 'package:equatable/equatable.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';

class CustomTemplateVariant extends Equatable {
  const CustomTemplateVariant({
    required this.id,
    required this.displayName,
    this.baseTemplateId,
    required this.subjective,
    required this.objective,
    required this.assessment,
    required this.plan,
    required this.createdAt,
  });

  final String id;
  final String displayName;
  final String? baseTemplateId;
  final String subjective;
  final String objective;
  final String assessment;
  final String plan;
  final DateTime createdAt;

  SoapNote toSoapNote() {
    return SoapNote(
      subjective: subjective,
      objective: objective,
      assessment: assessment,
      plan: plan,
    );
  }

  CustomTemplateVariant copyWith({
    String? id,
    String? displayName,
    String? baseTemplateId,
    String? subjective,
    String? objective,
    String? assessment,
    String? plan,
    DateTime? createdAt,
  }) {
    return CustomTemplateVariant(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      baseTemplateId: baseTemplateId ?? this.baseTemplateId,
      subjective: subjective ?? this.subjective,
      objective: objective ?? this.objective,
      assessment: assessment ?? this.assessment,
      plan: plan ?? this.plan,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        displayName,
        baseTemplateId,
        subjective,
        objective,
        assessment,
        plan,
        createdAt,
      ];
}
