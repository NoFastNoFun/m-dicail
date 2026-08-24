import 'package:equatable/equatable.dart';

sealed class PatientEvent extends Equatable {
  const PatientEvent();

  @override
  List<Object?> get props => [];
}

final class PatientsRequested extends PatientEvent {
  const PatientsRequested({this.query});

  final String? query;

  @override
  List<Object?> get props => [query];
}

final class PatientCreated extends PatientEvent {
  const PatientCreated({
    required this.mrn,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    this.sex,
    this.email,
    this.phone,
    this.address,
    this.notes,
  });

  final String mrn;
  final String firstName;
  final String lastName;
  final DateTime? birthDate;
  final String? sex;
  final String? email;
  final String? phone;
  final String? address;
  final String? notes;

  @override
  List<Object?> get props => [
        mrn,
        firstName,
        lastName,
        birthDate,
        sex,
        email,
        phone,
        address,
        notes,
      ];
}

final class PatientDeleted extends PatientEvent {
  const PatientDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

final class PatientUpdated extends PatientEvent {
  const PatientUpdated({
    required this.id,
    required this.mrn,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    this.sex,
    this.email,
    this.phone,
    this.address,
    this.notes,
  });

  final String id;
  final String mrn;
  final String firstName;
  final String lastName;
  final DateTime? birthDate;
  final String? sex;
  final String? email;
  final String? phone;
  final String? address;
  final String? notes;

  @override
  List<Object?> get props => [
        id,
        mrn,
        firstName,
        lastName,
        birthDate,
        sex,
        email,
        phone,
        address,
        notes,
      ];
}
