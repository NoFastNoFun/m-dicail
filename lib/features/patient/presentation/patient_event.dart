import 'package:equatable/equatable.dart';

sealed class PatientEvent extends Equatable {
  const PatientEvent();

  @override
  List<Object?> get props => [];
}

final class PatientsRequested extends PatientEvent {
  const PatientsRequested();
}

final class PatientCreated extends PatientEvent {
  const PatientCreated({
    required this.firstName,
    required this.lastName,
    this.birthDate,
  });

  final String firstName;
  final String lastName;
  final DateTime? birthDate;

  @override
  List<Object?> get props => [firstName, lastName, birthDate];
}

final class PatientDeleted extends PatientEvent {
  const PatientDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
