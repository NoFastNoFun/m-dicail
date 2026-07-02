import 'package:injectable/injectable.dart';
import 'package:medicail/core/network/auth_token_storage.dart';
import 'package:medicail/features/recording/data/repositories/api_recording_session_repository.dart';
import 'package:medicail/features/recording/data/repositories/secure_storage_recording_session_repository.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:medicail/core/config/app_config.dart';

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

  @override
  Future<List<RecordingSession>> getAll() async {
    final repo = await _getRepository();
    return repo.getAll();
  }

  @override
  Future<RecordingSession?> getById(String id) async {
    final repo = await _getRepository();
    return repo.getById(id);
  }

  @override
  Future<List<RecordingSession>> getByPatientId(String patientId) async {
    final repo = await _getRepository();
    return repo.getByPatientId(patientId);
  }

  @override
  Future<RecordingSession> save(RecordingSession session) async {
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
}
