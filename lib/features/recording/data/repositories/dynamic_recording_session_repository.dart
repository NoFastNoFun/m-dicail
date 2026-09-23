import 'package:injectable/injectable.dart';
import 'package:medicail/core/config/app_config.dart';
import 'package:medicail/core/network/auth_token_storage.dart';
import 'package:medicail/features/recording/data/repositories/api_recording_session_repository.dart';
import 'package:medicail/features/recording/data/repositories/secure_storage_recording_session_repository.dart';
import 'package:medicail/features/recording/data/repositories/session_tag_local_store.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:medicail/features/recording/domain/session_tags/session_tag_catalog.dart';
import 'package:medicail/features/tutorial/domain/tutorial_flow.dart';

@LazySingleton(as: RecordingSessionRepository)
class DynamicRecordingSessionRepository implements RecordingSessionRepository {
  DynamicRecordingSessionRepository(
    this._apiRepository,
    this._localRepository,
    this._tokenStorage,
    this._tagStore,
  );

  final ApiRecordingSessionRepository _apiRepository;
  final SecureStorageRecordingSessionRepository _localRepository;
  final AuthTokenStorage _tokenStorage;
  final SessionTagLocalStore _tagStore;

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
    final repository = await _getRepository();
    final sessions = await repository.getAll();
    final filtered = [
      for (final session in sessions)
        if (!_isTutorialSession(session)) session,
    ];
    return _tagStore.mergeAll(filtered);
  }

  @override
  Future<RecordingSession?> getById(String id) async {
    final repository = await _getRepository();
    final session = await repository.getById(id);
    if (session == null || _isTutorialSession(session)) {
      return null;
    }
    return _tagStore.merge(session);
  }

  @override
  Future<List<RecordingSession>> getByPatientId(String patientId) async {
    if (patientId == TutorialFlow.demoPatientId) {
      return const [];
    }
    final repository = await _getRepository();
    final sessions = await repository.getByPatientId(patientId);
    return _tagStore.mergeAll(sessions);
  }

  @override
  Future<RecordingSession> save(RecordingSession session) async {
    if (_isTutorialSession(session)) {
      return session;
    }
    final normalizedTag = SessionTagCatalog.normalize(session.tag);
    final toSave = normalizedTag == session.tag
        ? session
        : session.copyWith(
            tag: normalizedTag,
            clearTag: normalizedTag == null,
          );
    final repository = await _getRepository();
    final saved = await repository.save(toSave);
    // Keep local tag store as cache/fallback even when API persists tag.
    await _tagStore.setTag(saved.id, normalizedTag);
    // Also keep local guest/offline copy tagged when saving via API id change.
    if (saved.id != toSave.id && normalizedTag != null) {
      await _tagStore.setTag(toSave.id, null);
    }
    return saved.copyWith(
      tag: normalizedTag,
      clearTag: normalizedTag == null,
    );
  }

  @override
  Future<void> delete(String id) async {
    final repository = await _getRepository();
    await repository.delete(id);
    await _tagStore.setTag(id, null);
  }

  @override
  Future<void> clear() async {
    final repository = await _getRepository();
    await repository.clear();
  }

  @override
  Future<void> purgeTutorialSessions() async {
    final sessions = await _localRepository.getByPatientId(
      TutorialFlow.demoPatientId,
    );
    for (final session in sessions) {
      await _localRepository.delete(session.id);
      await _tagStore.setTag(session.id, null);
    }
  }
}
