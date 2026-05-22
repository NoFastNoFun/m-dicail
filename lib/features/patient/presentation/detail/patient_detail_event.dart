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
