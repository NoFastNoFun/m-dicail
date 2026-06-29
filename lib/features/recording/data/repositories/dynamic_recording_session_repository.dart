import 'package:injectable/injectable.dart';
import 'package:medicail/core/config/app_config.dart';
import 'package:medicail/core/network/auth_token_storage.dart';
import 'package:medicail/features/recording/data/repositories/api_recording_session_repository.dart';
import 'package:medicail/features/recording/data/repositories/secure_storage_recording_session_repository.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';

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
    return token == AppConfig.mockAdminToken
        ? _localRepository
        : _apiRepository;
  }

  @override
  Future<RecordingSession> create(RecordingSession session) async {
    final repository = await _getRepository();
    return repository.create(session);
  }

  @override
  Future<RecordingSession> save(RecordingSession session) async {
    final repository = await _getRepository();
    return repository.save(session);
  }

  @override
  Future<RecordingSession> associatePatient(
    String sessionId,
    String patientId,
  ) async {
    final repository = await _getRepository();
    return repository.associatePatient(sessionId, patientId);
  }

  @override
  Future<RecordingSession?> getById(String id) async {
    final repository = await _getRepository();
    return repository.getById(id);
  }

  @override
  Future<List<RecordingSession>> getByPatientId(String patientId) async {
    final repository = await _getRepository();
    return repository.getByPatientId(patientId);
  }

  @override
  Future<List<RecordingSession>> getAll() async {
    final repository = await _getRepository();
    return repository.getAll();
  }

  @override
  Future<void> delete(String id) async {
    final repository = await _getRepository();
    return repository.delete(id);
  }

  @override
  Future<void> clear() async {
    final repository = await _getRepository();
    return repository.clear();
  }
}
