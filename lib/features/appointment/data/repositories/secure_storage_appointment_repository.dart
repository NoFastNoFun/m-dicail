import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/storage/secure_collection_store.dart';
import 'package:medicail/features/appointment/data/models/appointment_model.dart';
import 'package:medicail/features/appointment/domain/entities/appointment.dart';
import 'package:medicail/features/appointment/domain/repositories/appointment_repository.dart';

@injectable
class SecureStorageAppointmentRepository implements AppointmentRepository {
  SecureStorageAppointmentRepository(this._storage) {
    _store = SecureCollectionStore<Appointment>(
      storage: _storage,
      key: appointmentsKey,
      fromJson: AppointmentModel.fromJson,
      toJson: (a) => AppointmentModel.fromEntity(a).toJson(),
    );
  }

  static const String appointmentsKey = 'appointments_v1';

  final FlutterSecureStorage _storage;
  late final SecureCollectionStore<Appointment> _store;

  @override
  Future<List<Appointment>> getByRange({
    required DateTime from,
    required DateTime to,
  }) async {
    final appointments = await _store.readAll();
    return appointments
        .where(
          (a) => !a.startsAt.isBefore(from) && a.startsAt.isBefore(to),
        )
        .toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  }

  @override
  Future<Appointment?> getById(String id) async {
    final appointments = await _store.readAll();
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

    await _store.mutate(
      (current) => <Appointment>[
        for (final item in current)
          if (item.id != saved.id) item,
        saved,
      ]..sort((a, b) => a.startsAt.compareTo(b.startsAt)),
    );

    return saved;
  }

  @override
  Future<void> delete(String id) async {
    await _store.mutate(
      (current) => [
        for (final appointment in current)
          if (appointment.id != id) appointment,
      ],
    );
  }

  @override
  Future<void> clear() => _store.clear();
}
