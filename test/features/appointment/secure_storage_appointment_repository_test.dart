import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:medicail/core/error/exceptions.dart';
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

  String? rawValue(String key) => _store[key];
  void rawSet(String key, String value) => _store[key] = value;
}

void main() {
  late SecureStorageAppointmentRepository repository;
  late _MemorySecureStorage storage;

  setUp(() {
    storage = _MemorySecureStorage();
    repository = SecureStorageAppointmentRepository(storage);
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

  // =========================================================================
  // R1 — read error must NOT delete data
  // =========================================================================
  group('R1 – read error safety', () {
    test('invalid JSON throws StorageException, data is preserved', () async {
      storage.rawSet(
        SecureStorageAppointmentRepository.appointmentsKey,
        'NOT_VALID_JSON!!!',
      );

      expect(
        () => repository.getByRange(
          from: DateTime(2026, 7, 21),
          to: DateTime(2026, 7, 22),
        ),
        throwsA(isA<StorageException>()),
      );

      // Data must still exist in storage.
      expect(
        storage.rawValue(SecureStorageAppointmentRepository.appointmentsKey),
        isNotNull,
      );
    });
  });

  // =========================================================================
  // R13 — concurrent saves must preserve both
  // =========================================================================
  group('R13 – concurrent save safety', () {
    test('two concurrent saves preserve both appointments', () async {
      // Seed one appointment.
      await repository.save(
        buildAppointment(id: 'a0', startsAt: DateTime(2026, 7, 21, 8)),
      );

      // Launch two concurrent saves.
      final futureA = repository.save(
        buildAppointment(id: 'a1', startsAt: DateTime(2026, 7, 21, 9)),
      );
      final futureB = repository.save(
        buildAppointment(id: 'a2', startsAt: DateTime(2026, 7, 21, 10)),
      );

      await Future.wait([futureA, futureB]);

      final all = await repository.getByRange(
        from: DateTime(2026, 7, 21),
        to: DateTime(2026, 7, 22),
      );

      final ids = all.map((a) => a.id).toSet();
      expect(ids, containsAll(['a0', 'a1', 'a2']),
          reason: 'All three appointments must be preserved');
    });

    test('concurrent save and delete produce correct result', () async {
      await repository.save(
        buildAppointment(id: 'a1', startsAt: DateTime(2026, 7, 21, 9)),
      );
      await repository.save(
        buildAppointment(id: 'a2', startsAt: DateTime(2026, 7, 21, 10)),
      );

      // Delete a1 and save a3 concurrently.
      final futureDelete = repository.delete('a1');
      final futureSave = repository.save(
        buildAppointment(id: 'a3', startsAt: DateTime(2026, 7, 21, 11)),
      );

      await Future.wait([futureDelete, futureSave]);

      final all = await repository.getByRange(
        from: DateTime(2026, 7, 21),
        to: DateTime(2026, 7, 22),
      );

      final ids = all.map((a) => a.id).toSet();
      expect(ids.contains('a1'), isFalse, reason: 'a1 was deleted');
      expect(ids.containsAll(['a2', 'a3']), isTrue,
          reason: 'a2 kept, a3 added');
    });
  });
}

