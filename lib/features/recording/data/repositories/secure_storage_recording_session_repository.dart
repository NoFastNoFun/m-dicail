import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/storage/secure_collection_store.dart';
import 'package:medicail/features/recording/data/models/recording_session_model.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';

@injectable
class SecureStorageRecordingSessionRepository
    implements RecordingSessionRepository {
  SecureStorageRecordingSessionRepository(this._storage) {
    _store = SecureCollectionStore<RecordingSession>(
      storage: _storage,
      key: _sessionsKey,
      fromJson: RecordingSessionModel.fromJson,
      toJson: (session) => RecordingSessionModel.fromEntity(session).toJson(),
    );
  }

  static const String _sessionsKey = 'recording_sessions_v1';

  final FlutterSecureStorage _storage;
  late final SecureCollectionStore<RecordingSession> _store;

  @override
  Future<List<RecordingSession>> getAll() async {
    return _store.readAll();
  }

  @override
  Future<RecordingSession?> getById(String id) async {
    final sessions = await _store.readAll();
    for (final session in sessions) {
      if (session.id == id) {
        return session;
      }
    }
    return null;
  }

  @override
  Future<List<RecordingSession>> getByPatientId(String patientId) async {
    final sessions = await _store.readAll();
    return [
      for (final session in sessions)
        if (session.patientId == patientId) session,
    ];
  }

  @override
  Future<RecordingSession> save(RecordingSession session) async {
    await _store.mutate((sessions) {
      return <RecordingSession>[
        for (final current in sessions)
          if (current.id != session.id) current,
        session,
      ]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    });
    return session;
  }

  @override
  Future<void> delete(String id) async {
    await _store.mutate((sessions) {
      final nextSessions = <RecordingSession>[];
      for (final session in sessions) {
        if (session.id != id) {
          nextSessions.add(session);
        }
      }
      return nextSessions;
    });
  }

  @override
  Future<void> clear() async {
    return _store.clear();
  }

  @override
  Future<void> purgeTutorialSessions() async {
    // No-op: tutorial sessions are filtered by DynamicRecordingSessionRepository.
  }
}
