import 'package:injectable/injectable.dart';
import 'package:medicail/core/config/app_config.dart';
import 'package:medicail/core/network/auth_token_storage.dart';
import 'package:medicail/features/recording/data/repositories/api_recording_session_repository.dart';
import 'package:medicail/features/recording/data/repositories/secure_storage_recording_session_repository.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:medicail/features/tutorial/domain/tutorial_flow.dart';

@LazySingleton(as: RecordingSessionRepository)
class DynamicRecordingSessionRepository implements RecordingSessionRepository {
  DynamicRecordingSessionRepository(
    this._apiRepository,
    this._localRepository,
    this._tokenStorage,
  );

  final ApiRecordingSessionRepository _apiRepository;
  final SecureStorageRecordingSessionRepository _localRepository;
  final AuthTokenStorage _tokenStorage;

  Future<RecordingSessionRepository> _getRepository() async {
    final token = await _tokenStorage.readToken();
    if (AppConfig.isOfflineMode(token)) {
      return _localRepository;
    }
    return _apiRepository;
  }

  bool _isTutorialSession(RecordingSession session) {
    return session.patientId == TutorialFlow.demoPatientId;
  }

  @override
  Future<List<RecordingSession>> getAll() async {
    final repo = await _getRepository();
    final sessions = await repo.getAll();
    return [
      for (final session in sessions)
        if (!_isTutorialSession(session)) session,
    ];
  }

  @override
  Future<RecordingSession?> getById(String id) async {
    final repo = await _getRepository();
    final session = await repo.getById(id);
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
    final repo = await _getRepository();
    return repo.getByPatientId(patientId);
  }

  @override
  Future<RecordingSession> save(RecordingSession session) async {
    if (_isTutorialSession(session)) {
      return session;
    }
    final repo = await _getRepository();
    return repo.save(session);
  }

  @override
  Future<void> delete(String id) async {
    final repo = await _getRepository();
    await repo.delete(id);
  }

  @override
  Future<void> clear() async {
    final repo = await _getRepository();
    await repo.clear();
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
