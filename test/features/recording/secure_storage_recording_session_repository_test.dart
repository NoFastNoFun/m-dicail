import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/features/recording/data/repositories/secure_storage_recording_session_repository.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';

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
  late SecureStorageRecordingSessionRepository repository;

  setUp(() {
    repository = SecureStorageRecordingSessionRepository(_MemorySecureStorage());
  });

  RecordingSession buildSession({
    required String id,
    required DateTime startedAt,
    String? patientId,
  }) {
    return RecordingSession(
      id: id,
      patientId: patientId,
      startedAt: startedAt,
      status: RecordingSessionStatus.completed,
    );
  }

  test('save and getById returns saved session', () async {
    final session = buildSession(
      id: 'session_1',
      startedAt: DateTime(2026, 7, 21, 9),
      patientId: 'patient_1',
    );
    await repository.save(session);

    final loaded = await repository.getById('session_1');
    expect(loaded, isNotNull);
    expect(loaded!.id, 'session_1');
    expect(loaded.patientId, 'patient_1');
  });

  test('getAll returns sessions sorted by startedAt descending', () async {
    final s1 = buildSession(id: 's1', startedAt: DateTime(2026, 7, 21, 9));
    final s2 = buildSession(id: 's2', startedAt: DateTime(2026, 7, 21, 10));
    final s3 = buildSession(id: 's3', startedAt: DateTime(2026, 7, 21, 8));

    await repository.save(s1);
    await repository.save(s2);
    await repository.save(s3);

    final all = await repository.getAll();
    expect(all.map((s) => s.id).toList(), ['s2', 's1', 's3']);
  });

  test('getByPatientId filters sessions by patient id', () async {
    await repository.save(
      buildSession(
        id: 's1',
        startedAt: DateTime(2026, 7, 21, 9),
        patientId: 'p1',
      ),
    );
    await repository.save(
      buildSession(
        id: 's2',
        startedAt: DateTime(2026, 7, 21, 10),
        patientId: 'p2',
      ),
    );

    final p1Sessions = await repository.getByPatientId('p1');
    expect(p1Sessions.length, 1);
    expect(p1Sessions.first.id, 's1');
  });

  test('delete removes specified session', () async {
    await repository.save(
      buildSession(id: 's1', startedAt: DateTime(2026, 7, 21, 9)),
    );
    await repository.delete('s1');

    final loaded = await repository.getById('s1');
    expect(loaded, isNull);
  });

  test('clear removes all sessions', () async {
    await repository.save(
      buildSession(id: 's1', startedAt: DateTime(2026, 7, 21, 9)),
    );
    await repository.clear();

    final all = await repository.getAll();
    expect(all, isEmpty);
  });
}
