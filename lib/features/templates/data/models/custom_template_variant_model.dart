import 'package:medicail/features/templates/domain/entities/custom_template_variant.dart';

class CustomTemplateVariantModel {
  const CustomTemplateVariantModel({
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

  factory CustomTemplateVariantModel.fromEntity(CustomTemplateVariant entity) {
    return CustomTemplateVariantModel(
      id: entity.id,
      displayName: entity.displayName,
      baseTemplateId: entity.baseTemplateId,
      subjective: entity.subjective,
      objective: entity.objective,
      assessment: entity.assessment,
      plan: entity.plan,
      createdAt: entity.createdAt,
    );
  }

  factory CustomTemplateVariantModel.fromJson(Map<String, dynamic> json) {
    return CustomTemplateVariantModel(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      baseTemplateId: json['baseTemplateId'] as String?,
      subjective: json['subjective'] as String,
      objective: json['objective'] as String,
      assessment: json['assessment'] as String,
      plan: json['plan'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  CustomTemplateVariant toEntity() {
    return CustomTemplateVariant(
      id: id,
      displayName: displayName,
      baseTemplateId: baseTemplateId,
      subjective: subjective,
      objective: objective,
      assessment: assessment,
      plan: plan,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'baseTemplateId': baseTemplateId,
      'subjective': subjective,
      'objective': objective,
      'assessment': assessment,
      'plan': plan,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
