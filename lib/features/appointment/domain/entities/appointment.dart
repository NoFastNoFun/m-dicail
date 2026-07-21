import 'package:equatable/equatable.dart';

enum AppointmentStatus {
  scheduled,
  cancelled,
  completed;

  static AppointmentStatus fromString(String? value) {
    switch (value) {
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'completed':
        return AppointmentStatus.completed;
      case 'scheduled':
      default:
        return AppointmentStatus.scheduled;
    }
  }

  String get apiValue => name;
}

class Appointment extends Equatable {
  const Appointment({
    required this.id,
    required this.patientId,
    required this.startsAt,
    required this.createdAt,
    required this.updatedAt,
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
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isCancelled => status == AppointmentStatus.cancelled;

  Appointment copyWith({
    String? id,
    String? patientId,
    DateTime? startsAt,
    DateTime? endsAt,
    AppointmentStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearEndsAt = false,
    bool clearNotes = false,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      startsAt: startsAt ?? this.startsAt,
      endsAt: clearEndsAt ? null : endsAt ?? this.endsAt,
      status: status ?? this.status,
      notes: clearNotes ? null : notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        patientId,
        startsAt,
        endsAt,
        status,
        notes,
        createdAt,
        updatedAt,
      ];
}
