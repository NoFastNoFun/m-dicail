import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:medicail/features/appointment/data/repositories/secure_storage_appointment_repository.dart';
import 'package:medicail/features/appointment/domain/entities/appointment.dart';

class _MemorySecureStorage extends FlutterSecureStorage {
  final Map<String, String> _store = {};

  @override
  Future<String?> read({
    required String key,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _store[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _store.remove(key);
    } else {
      _store[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.remove(key);
  }
}

void main() {
  late SecureStorageAppointmentRepository repository;

  setUp(() {
    repository = SecureStorageAppointmentRepository(_MemorySecureStorage());
  });

  Appointment buildAppointment({
    required String id,
    required DateTime startsAt,
  }) {
    final now = DateTime(2026, 7, 21, 8);
    return Appointment(
      id: id,
      patientId: 'patient_1',
      startsAt: startsAt,
      endsAt: startsAt.add(const Duration(minutes: 30)),
      createdAt: now,
      updatedAt: now,
    );
  }

  test('save generates id when empty and persists', () async {
    final saved = await repository.save(
      buildAppointment(id: '', startsAt: DateTime(2026, 7, 21, 9)),
    );

    expect(saved.id, isNotEmpty);
    expect(saved.id, startsWith('appointment_'));

    final loaded = await repository.getById(saved.id);
    expect(loaded, isNotNull);
    expect(loaded!.patientId, 'patient_1');
  });

  test('getByRange filters by day bounds', () async {
    await repository.save(
      buildAppointment(id: 'a1', startsAt: DateTime(2026, 7, 21, 9)),
    );
    await repository.save(
      buildAppointment(id: 'a2', startsAt: DateTime(2026, 7, 22, 9)),
    );

    final day = await repository.getByRange(
      from: DateTime(2026, 7, 21),
      to: DateTime(2026, 7, 22),
    );

    expect(day.map((a) => a.id), ['a1']);
  });

  test('delete removes appointment', () async {
    await repository.save(
      buildAppointment(id: 'a1', startsAt: DateTime(2026, 7, 21, 9)),
    );
    await repository.delete('a1');
    expect(await repository.getById('a1'), isNull);
  });
}
