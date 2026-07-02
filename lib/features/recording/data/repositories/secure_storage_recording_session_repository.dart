import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/features/recording/data/models/recording_session_model.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';

@injectable
class SecureStorageRecordingSessionRepository
    implements RecordingSessionRepository {
  const SecureStorageRecordingSessionRepository(this._storage);

  static const String _sessionsKey = 'recording_sessions_v1';

  final FlutterSecureStorage _storage;

  @override
  Future<List<RecordingSession>> getAll() async {
    return _readSessions();
  }

  @override
  Future<RecordingSession?> getById(String id) async {
    final sessions = await _readSessions();
    for (final session in sessions) {
      if (session.id == id) {
        return session;
      }
    }
    return null;
  }

  @override
  Future<List<RecordingSession>> getByPatientId(String patientId) async {
    final sessions = await _readSessions();
    return [
      for (final session in sessions)
        if (session.patientId == patientId) session,
    ];
  }

  @override
  Future<void> save(RecordingSession session) async {
    final sessions = await _readSessions();
    final nextSessions = <RecordingSession>[
      for (final current in sessions)
        if (current.id != session.id) current,
      session,
    ]..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    await _writeSessions(nextSessions);
  }

  @override
  Future<void> delete(String id) async {
    final sessions = await _readSessions();
    final nextSessions = <RecordingSession>[];

    for (final session in sessions) {
      if (session.id != id) {
        nextSessions.add(session);
      }
    }

    await _writeSessions(nextSessions);
  }

  @override
  Future<void> clear() async {
    return _storage.delete(key: _sessionsKey);
  }

  Future<List<RecordingSession>> _readSessions() async {
    try {
      final raw = await _storage.read(key: _sessionsKey);
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
          .map(RecordingSessionModel.fromJson)
          .toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    } catch (e) {
      // Si le KeyStore Android est désynchronisé (PlatformException),
      // on purge les données corrompues pour ne pas bloquer l'app.
      await _storage.delete(key: _sessionsKey);
      return const [];
    }
  }

  Future<void> _writeSessions(List<RecordingSession> sessions) {
    final encoded = jsonEncode(
      sessions
          .map(RecordingSessionModel.fromEntity)
          .map((session) => session.toJson())
          .toList(),
    );
    return _storage.write(key: _sessionsKey, value: encoded);
  }
}
