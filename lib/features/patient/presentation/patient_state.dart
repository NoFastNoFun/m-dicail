import 'package:equatable/equatable.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';

sealed class PatientState extends Equatable {
  const PatientState();

  @override
  List<Object?> get props => [];
}

final class PatientInitial extends PatientState {
  const PatientInitial();
}

final class PatientLoading extends PatientState {
  const PatientLoading();
}

final class PatientLoaded extends PatientState {
  const PatientLoaded(this.patients);

  final List<Patient> patients;

  @override
  List<Object?> get props => [patients];
}

final class PatientFailure extends PatientState {
  const PatientFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class PatientMrnConflict extends PatientState {
  const PatientMrnConflict();
}

class PatientCreateSuccess extends PatientState {
  const PatientCreateSuccess();
}
