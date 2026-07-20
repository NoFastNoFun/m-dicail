import 'package:equatable/equatable.dart';
import 'package:medicail/features/exo_patient/domain/entities/exercise.dart';
import 'package:medicail/features/exo_patient/domain/entities/patient_exercise.dart';

sealed class ExoPatientState extends Equatable {
  const ExoPatientState();

  @override
  List<Object?> get props => [];
}

final class ExoPatientInitial extends ExoPatientState {
  const ExoPatientInitial();
}

final class ExoPatientLoading extends ExoPatientState {
  const ExoPatientLoading();
}

final class ExoPatientLoaded extends ExoPatientState {
  const ExoPatientLoaded({
    required this.catalog,
    required this.assignments,
  });

  final List<Exercise> catalog;
  final List<PatientExercise> assignments;

  @override
  List<Object?> get props => [catalog, assignments];
}

final class ExoPatientFailure extends ExoPatientState {
  const ExoPatientFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ExoPatientActionSuccess extends ExoPatientState {
  const ExoPatientActionSuccess({
    required this.catalog,
    required this.assignments,
    required this.message,
    this.affectedAssignmentId,
  });

  final List<Exercise> catalog;
  final List<PatientExercise> assignments;
  final String message;
  final String? affectedAssignmentId;

  @override
  List<Object?> get props => [
        catalog,
        assignments,
        message,
        affectedAssignmentId,
      ];
}
