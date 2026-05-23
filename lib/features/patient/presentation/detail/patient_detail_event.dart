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

class RecordingSessionDeleteRequested extends PatientDetailEvent {
  const RecordingSessionDeleteRequested({
    required this.patientId,
    required this.sessionId,
  });

  final String patientId;
  final String sessionId;

  @override
  List<Object?> get props => [patientId, sessionId];
}
