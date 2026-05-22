import 'package:equatable/equatable.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';

sealed class PatientDetailState extends Equatable {
  const PatientDetailState();

  @override
  List<Object?> get props => [];
}

class PatientDetailInitial extends PatientDetailState {
  const PatientDetailInitial();
}

class PatientDetailLoading extends PatientDetailState {
  const PatientDetailLoading();
}

class PatientDetailLoaded extends PatientDetailState {
  const PatientDetailLoaded({
    required this.patient,
    required this.sessions,
  });

  final Patient? patient;
  final List<RecordingSession> sessions;

  @override
  List<Object?> get props => [patient, sessions];
}

class PatientDetailFailure extends PatientDetailState {
  const PatientDetailFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
