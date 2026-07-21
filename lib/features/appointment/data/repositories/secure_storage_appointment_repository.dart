import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/features/appointment/data/models/appointment_model.dart';
import 'package:medicail/features/appointment/domain/entities/appointment.dart';
import 'package:medicail/features/appointment/domain/repositories/appointment_repository.dart';

@injectable
class SecureStorageAppointmentRepository implements AppointmentRepository {
  const SecureStorageAppointmentRepository(this._storage);

  static const String appointmentsKey = 'appointments_v1';

  final FlutterSecureStorage _storage;

  @override
  Future<List<Appointment>> getByRange({
    required DateTime from,
    required DateTime to,
  }) async {
    final appointments = await _readAppointments();
    return appointments
        .where(
          (a) =>
              !a.startsAt.isBefore(from) && a.startsAt.isBefore(to),
        )
        .toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  }

  @override
  Future<Appointment?> getById(String id) async {
    final appointments = await _readAppointments();
    for (final appointment in appointments) {
      if (appointment.id == id) {
        return appointment;
      }
    }
    return null;
  }

  @override
  Future<Appointment> save(Appointment appointment) async {
    final now = DateTime.now();
    final saved = appointment.id.isEmpty
        ? appointment.copyWith(
            id: 'appointment_${now.toUtc().microsecondsSinceEpoch}',
            createdAt: now,
            updatedAt: now,
          )
        : appointment.copyWith(updatedAt: now);

    final appointments = await _readAppointments();
    final next = <Appointment>[
      for (final current in appointments)
        if (current.id != saved.id) current,
      saved,
    ]..sort((a, b) => a.startsAt.compareTo(b.startsAt));

    await _writeAppointments(next);
    return saved;
  }

  @override
  Future<void> delete(String id) async {
    final appointments = await _readAppointments();
    final next = [
      for (final appointment in appointments)
        if (appointment.id != id) appointment,
    ];
    await _writeAppointments(next);
  }

  @override
  Future<void> clear() => _storage.delete(key: appointmentsKey);

  Future<List<Appointment>> _readAppointments() async {
    try {
      final raw = await _storage.read(key: appointmentsKey);
      if (raw == null || raw.isEmpty) {
        return const [];
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }

      return decoded
          .whereType<Map>()
          .map((json) => Map<String, dynamic>.from(json))
          .map(AppointmentModel.fromJson)
          .toList()
        ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    } catch (_) {
      await _storage.delete(key: appointmentsKey);
      return const [];
    }
  }

  Future<void> _writeAppointments(List<Appointment> appointments) {
    final encoded = jsonEncode(
      appointments
          .map(AppointmentModel.fromEntity)
          .map((a) => a.toJson())
          .toList(),
    );
    return _storage.write(key: appointmentsKey, value: encoded);
  }
}
