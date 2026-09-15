import 'package:equatable/equatable.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';

sealed class GlobalSearchHit extends Equatable {
  const GlobalSearchHit();
}

final class GlobalSearchPatientHit extends GlobalSearchHit {
  const GlobalSearchPatientHit(this.patient);

  final Patient patient;

  @override
  List<Object?> get props => [patient.id];
}

final class GlobalSearchSessionHit extends GlobalSearchHit {
  const GlobalSearchSessionHit({
    required this.session,
    this.patientName,
    this.snippet,
  });

  final RecordingSession session;
  final String? patientName;
  final String? snippet;

  @override
  List<Object?> get props => [session.id];
}

class GlobalSearchResults extends Equatable {
  const GlobalSearchResults({
    this.patients = const [],
    this.sessions = const [],
  });

  final List<GlobalSearchPatientHit> patients;
  final List<GlobalSearchSessionHit> sessions;

  bool get isEmpty => patients.isEmpty && sessions.isEmpty;

  @override
  List<Object?> get props => [patients, sessions];
}
