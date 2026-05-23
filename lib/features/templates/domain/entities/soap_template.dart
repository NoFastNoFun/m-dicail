import 'package:equatable/equatable.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';

class SoapTemplate extends Equatable {
  const SoapTemplate({
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

  SoapNote toSoapNote() {
    return SoapNote(
      subjective: subjectiveDefault,
      objective: objectiveDefault,
      assessment: assessmentDefault,
      plan: planDefault,
    );
  }

  @override
  List<Object?> get props => [
        id,
        pathologyName,
        subjectiveDefault,
        objectiveDefault,
        assessmentDefault,
        planDefault,
        createdAt,
      ];
}
