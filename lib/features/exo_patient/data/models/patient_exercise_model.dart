import 'package:medicail/features/exo_patient/domain/entities/patient_exercise.dart';
import 'package:medicail/features/exo_patient/domain/entities/patient_exercise_status.dart';

final class PatientExerciseModel extends PatientExercise {
  const PatientExerciseModel({
    required super.id,
    required super.patientId,
    required super.exerciseId,
    required super.assignedAt,
    required super.status,
    super.frequency,
    super.notes,
    super.updatedAt,
  });

  factory PatientExerciseModel.fromEntity(PatientExercise assignment) {
    return PatientExerciseModel(
      id: assignment.id,
      patientId: assignment.patientId,
      exerciseId: assignment.exerciseId,
      assignedAt: assignment.assignedAt,
      status: assignment.status,
      frequency: assignment.frequency,
      notes: assignment.notes,
      updatedAt: assignment.updatedAt,
    );
  }

  factory PatientExerciseModel.fromJson(Map<String, dynamic> json) {
    return PatientExerciseModel(
      id: json['id'] as String,
      patientId: json['patientId'] as String? ?? '',
      exerciseId: json['exerciseId'] as String? ?? '',
      assignedAt: DateTime.parse(json['assignedAt'] as String),
      status: PatientExerciseStatusX.fromJson(json['status'] as String?),
      frequency: json['frequency'] as String?,
      notes: json['notes'] as String?,
      updatedAt: _parseNullableDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'exerciseId': exerciseId,
      'assignedAt': assignedAt.toIso8601String(),
      'status': status.jsonValue,
      'frequency': frequency,
      'notes': notes,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static DateTime? _parseNullableDate(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.parse(value);
  }
}
