import 'package:injectable/injectable.dart';
import 'package:medicail/features/recording/data/repositories/secure_storage_recording_session_repository.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:medicail/features/tutorial/domain/tutorial_flow.dart';

@LazySingleton(as: RecordingSessionRepository)
class DynamicRecordingSessionRepository implements RecordingSessionRepository {
  DynamicRecordingSessionRepository(this._localRepository);

  final SecureStorageRecordingSessionRepository _localRepository;

  bool _isTutorialSession(RecordingSession session) {
    return session.patientId == TutorialFlow.demoPatientId;
  }

  @override
  Future<List<RecordingSession>> getAll() async {
    final sessions = await _localRepository.getAll();
    return [
      for (final session in sessions)
        if (!_isTutorialSession(session)) session,
    ];
  }

  @override
  Future<RecordingSession?> getById(String id) async {
    final session = await _localRepository.getById(id);
    if (session == null || _isTutorialSession(session)) {
      return null;
    }
    return session;
  }

  @override
  Future<List<RecordingSession>> getByPatientId(String patientId) async {
    if (patientId == TutorialFlow.demoPatientId) {
      return const [];
    }
    return _localRepository.getByPatientId(patientId);
  }

  @override
  Future<void> save(RecordingSession session) async {
    if (_isTutorialSession(session)) {
      return;
    }
    await _localRepository.save(session);
  }

  @override
  Future<void> delete(String id) async {
    await _localRepository.delete(id);
  }

  @override
  Future<void> clear() async {
    await _localRepository.clear();
  }

  @override
  Future<void> purgeTutorialSessions() async {
    final sessions = await _localRepository.getByPatientId(
      TutorialFlow.demoPatientId,
    );
    for (final session in sessions) {
      await _localRepository.delete(session.id);
    }
  }
}
