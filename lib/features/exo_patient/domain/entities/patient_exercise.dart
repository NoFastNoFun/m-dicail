import 'package:equatable/equatable.dart';
import 'package:medicail/features/exo_patient/domain/entities/patient_exercise_status.dart';

class PatientExercise extends Equatable {
  const PatientExercise({
    required this.id,
    required this.patientId,
    required this.exerciseId,
    required this.assignedAt,
    required this.status,
    this.frequency,
    this.notes,
    this.updatedAt,
  });

  final String id;
  final String patientId;
  final String exerciseId;
  final DateTime assignedAt;
  final PatientExerciseStatus status;
  final String? frequency;
  final String? notes;
  final DateTime? updatedAt;

  bool get isActive =>
      status == PatientExerciseStatus.assigned ||
      status == PatientExerciseStatus.inProgress;

  PatientExercise copyWith({
    String? id,
    String? patientId,
    String? exerciseId,
    DateTime? assignedAt,
    PatientExerciseStatus? status,
    String? frequency,
    String? notes,
    DateTime? updatedAt,
    bool clearFrequency = false,
    bool clearNotes = false,
    bool clearUpdatedAt = false,
  }) {
    return PatientExercise(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      exerciseId: exerciseId ?? this.exerciseId,
      assignedAt: assignedAt ?? this.assignedAt,
      status: status ?? this.status,
      frequency: clearFrequency ? null : frequency ?? this.frequency,
      notes: clearNotes ? null : notes ?? this.notes,
      updatedAt: clearUpdatedAt ? null : updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        patientId,
        exerciseId,
        assignedAt,
        status,
        frequency,
        notes,
        updatedAt,
      ];
}
