import 'package:equatable/equatable.dart';

sealed class PatientDetailEvent extends Equatable {
  const PatientDetailEvent();

  @override
  List<Object?> get props => [];
}

class PatientDetailRequested extends PatientDetailEvent {
  const PatientDetailRequested(this.patientId);

  final String patientId;

  @override
  List<Object?> get props => [patientId];
}

class PatientDetailSessionDeleted extends PatientDetailEvent {
  const PatientDetailSessionDeleted({
    required this.patientId,
    required this.sessionId,
  });

  final String patientId;
  final String sessionId;

  @override
  List<Object?> get props => [patientId, sessionId];
}

class PatientDetailArchived extends PatientDetailEvent {
  const PatientDetailArchived(this.patientId);

  final String patientId;

  @override
  List<Object?> get props => [patientId];
}

class PatientDetailUnarchived extends PatientDetailEvent {
  const PatientDetailUnarchived(this.patientId);

  final String patientId;

  @override
  List<Object?> get props => [patientId];
}

class PatientDetailDeleted extends PatientDetailEvent {
  const PatientDetailDeleted(this.patientId);

  final String patientId;

  @override
  List<Object?> get props => [patientId];
}
