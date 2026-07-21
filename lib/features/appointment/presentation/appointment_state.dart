import 'package:equatable/equatable.dart';
import 'package:medicail/features/appointment/domain/entities/appointment.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';

class AppointmentListItem extends Equatable {
  const AppointmentListItem({
    required this.appointment,
    this.patient,
  });

  final Appointment appointment;
  final Patient? patient;

  String get patientDisplayName {
    final p = patient;
    if (p == null) {
      return appointment.patientId;
    }
    return p.displayName;
  }

  @override
  List<Object?> get props => [appointment, patient];
}

sealed class AppointmentState extends Equatable {
  const AppointmentState();

  @override
  List<Object?> get props => [];
}

final class AppointmentInitial extends AppointmentState {
  const AppointmentInitial();
}

final class AppointmentLoading extends AppointmentState {
  const AppointmentLoading();
}

final class AppointmentDayLoaded extends AppointmentState {
  const AppointmentDayLoaded({
    required this.day,
    required this.items,
  });

  final DateTime day;
  final List<AppointmentListItem> items;

  @override
  List<Object?> get props => [day, items];
}

final class AppointmentFailure extends AppointmentState {
  const AppointmentFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class AppointmentSaveSuccess extends AppointmentState {
  const AppointmentSaveSuccess(this.appointmentId);

  final String appointmentId;

  @override
  List<Object?> get props => [appointmentId];
}
