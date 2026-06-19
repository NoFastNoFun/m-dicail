import 'package:injectable/injectable.dart';
import 'package:medicail/core/network/api_client.dart';
import 'package:medicail/features/recording/data/models/recording_session_model.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';

@lazySingleton
class ApiRecordingSessionRepository implements RecordingSessionRepository {
  ApiRecordingSessionRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<RecordingSession> create(RecordingSession session) async {
    final model = RecordingSessionModel.fromEntity(session);
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/recording-sessions',
      data: model.toCreateApiJson(),
    );
    return RecordingSessionModel.fromJson(
      response.data ?? const <String, dynamic>{},
    );
  }

  @override
  Future<RecordingSession> save(RecordingSession session) async {
    final model = RecordingSessionModel.fromEntity(session);
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/recording-sessions/${session.id}',
      data: model.toUpdateApiJson(),
    );
    return RecordingSessionModel.fromJson(
      response.data ?? const <String, dynamic>{},
    );
  }

  @override
  Future<RecordingSession> associatePatient(
    String sessionId,
    String patientId,
  ) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/recording-sessions/$sessionId/patient',
      data: {'patient_id': patientId},
    );
    return RecordingSessionModel.fromJson(
      response.data ?? const <String, dynamic>{},
    );
  }

  @override
  Future<RecordingSession?> getById(String id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/recording-sessions/$id',
    );
    final data = response.data;
    return data == null ? null : RecordingSessionModel.fromJson(data);
  }

  @override
  Future<List<RecordingSession>> getByPatientId(String patientId) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/patients/$patientId/recording-sessions',
    );
    final sessions = (response.data ?? const <dynamic>[])
        .map(
          (json) => RecordingSessionModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions;
  }

  @override
  Future<List<RecordingSession>> getAll() async => const [];

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> clear() async {}
}
