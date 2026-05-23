import 'package:medicail/features/templates/domain/entities/soap_template.dart';

class SoapTemplateModel {
  const SoapTemplateModel({
    required this.id,
    required this.pathologyName,
    required this.subjectiveDefault,
    required this.objectiveDefault,
    required this.assessmentDefault,
    required this.planDefault,
    required this.createdAt,
  });

  final String id;
  final String pathologyName;
  final String subjectiveDefault;
  final String objectiveDefault;
  final String assessmentDefault;
  final String planDefault;
  final DateTime createdAt;

  factory SoapTemplateModel.fromEntity(SoapTemplate entity) {
    return SoapTemplateModel(
      id: entity.id,
      pathologyName: entity.pathologyName,
      subjectiveDefault: entity.subjectiveDefault,
      objectiveDefault: entity.objectiveDefault,
      assessmentDefault: entity.assessmentDefault,
      planDefault: entity.planDefault,
      createdAt: entity.createdAt,
    );
  }

  factory SoapTemplateModel.fromJson(Map<String, dynamic> json) {
    return SoapTemplateModel(
      id: json['id'] as String,
      pathologyName: json['pathologyName'] as String,
      subjectiveDefault: json['subjectiveDefault'] as String,
      objectiveDefault: json['objectiveDefault'] as String,
      assessmentDefault: json['assessmentDefault'] as String,
      planDefault: json['planDefault'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  SoapTemplate toEntity() {
    return SoapTemplate(
      id: id,
      pathologyName: pathologyName,
      subjectiveDefault: subjectiveDefault,
      objectiveDefault: objectiveDefault,
      assessmentDefault: assessmentDefault,
      planDefault: planDefault,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pathologyName': pathologyName,
      'subjectiveDefault': subjectiveDefault,
      'objectiveDefault': objectiveDefault,
      'assessmentDefault': assessmentDefault,
      'planDefault': planDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
