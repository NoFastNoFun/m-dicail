import 'package:equatable/equatable.dart';
import 'package:medicail/features/appointment/domain/entities/appointment.dart';

sealed class AppointmentEvent extends Equatable {
  const AppointmentEvent();

  @override
  List<Object?> get props => [];
}

final class AppointmentsDayRequested extends AppointmentEvent {
  const AppointmentsDayRequested(this.day);

  final DateTime day;

  @override
  List<Object?> get props => [day];
}

final class AppointmentsUpcomingRequested extends AppointmentEvent {
  const AppointmentsUpcomingRequested({
    this.limit = 5,
    this.horizonDays = 30,
    this.showLoading = true,
  });

  final int limit;
  final int horizonDays;
  final bool showLoading;

  @override
  List<Object?> get props => [limit, horizonDays, showLoading];
}

final class AppointmentSaved extends AppointmentEvent {
  const AppointmentSaved({
    this.id = '',
    required this.patientId,
    required this.startsAt,
    this.endsAt,
    this.status = AppointmentStatus.scheduled,
    this.notes,
  });

  final String id;
  final String patientId;
  final DateTime startsAt;
  final DateTime? endsAt;
  final AppointmentStatus status;
  final String? notes;

  @override
  List<Object?> get props => [id, patientId, startsAt, endsAt, status, notes];
}

final class AppointmentCancelled extends AppointmentEvent {
  const AppointmentCancelled(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

final class AppointmentDeleted extends AppointmentEvent {
  const AppointmentDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
