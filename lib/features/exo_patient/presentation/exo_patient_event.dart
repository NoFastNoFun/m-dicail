import 'package:equatable/equatable.dart';
import 'package:medicail/features/exo_patient/domain/entities/patient_exercise_status.dart';

sealed class ExoPatientEvent extends Equatable {
  const ExoPatientEvent();

  @override
  List<Object?> get props => [];
}

final class ExoPatientDataRequested extends ExoPatientEvent {
  const ExoPatientDataRequested(this.patientId);

  final String patientId;

  @override
  List<Object?> get props => [patientId];
}

final class ExoPatientAssignRequested extends ExoPatientEvent {
  const ExoPatientAssignRequested({
    required this.patientId,
    required this.exerciseId,
    this.frequency,
    this.notes,
  });

  final String patientId;
  final String exerciseId;
  final String? frequency;
  final String? notes;

  @override
  List<Object?> get props => [patientId, exerciseId, frequency, notes];
}

final class ExoPatientStatusUpdateRequested extends ExoPatientEvent {
  const ExoPatientStatusUpdateRequested({
    required this.patientId,
    required this.assignmentId,
    required this.status,
  });

  final String patientId;
  final String assignmentId;
  final PatientExerciseStatus status;

  @override
  List<Object?> get props => [patientId, assignmentId, status];
}

final class ExoPatientUnassignRequested extends ExoPatientEvent {
  const ExoPatientUnassignRequested({
    required this.patientId,
    required this.assignmentId,
  });

  final String patientId;
  final String assignmentId;

  @override
  List<Object?> get props => [patientId, assignmentId];
}
