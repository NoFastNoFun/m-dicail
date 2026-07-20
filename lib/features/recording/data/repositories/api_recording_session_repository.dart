import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:medicail/core/network/api_client.dart';
import 'package:medicail/features/recording/data/models/recording_session_model.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';

@injectable
class ApiRecordingSessionRepository implements RecordingSessionRepository {
  ApiRecordingSessionRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<RecordingSession>> getAll() async {
    // Le backend ne permet pas de lister toutes les sessions sans un patientId
    return const [];
  }

  @override
  Future<RecordingSession?> getById(String id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('/recording-sessions/$id');
      final data = response.data;
      if (data == null) {
        return null;
      }
      return RecordingSessionModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<List<RecordingSession>> getByPatientId(String patientId) async {
    final response = await _apiClient.get<List<dynamic>>('/patients/$patientId/recording-sessions');
    final data = response.data;
    if (data == null) {
      return [];
    }
    return data
        .map((json) => RecordingSessionModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<RecordingSession> save(RecordingSession session) async {
    final model = RecordingSessionModel.fromEntity(session);

    // Si l'id est vide ou généré en local (commence par local_), c'est une création
    if (session.id.isEmpty || session.id.startsWith('local_')) {
      final payload = <String, dynamic>{
        'started_at': model.startedAt.toIso8601String(),
        'status': model.status.name,
      };
      if (model.transcript.isNotEmpty) {
        payload['transcript'] = model.transcript;
      }
      if (model.patientId != null && model.patientId!.isNotEmpty) {
        payload['patient_id'] = model.patientId;
      }

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/recording-sessions',
        data: payload,
      );
      final data = response.data;
      if (data == null) {
        throw const ServerException('Aucune donnee session retournee.');
      }
      return RecordingSessionModel.fromJson(data);
    }

    // Sinon mise a jour (PUT)
    final payload = <String, dynamic>{
      'status': model.status.name,
      'transcript': model.transcript,
    };
    if (model.endedAt != null) {
      payload['ended_at'] = model.endedAt!.toIso8601String();
    }
    if (model.soapNote != null) {
      payload['soap_note'] = model.soapNote!.toJson();
    }
    if (model.patientId != null) {
      payload['patient_id'] = model.patientId;
    }

    final response = await _apiClient.put<Map<String, dynamic>>(
      '/recording-sessions/${session.id}',
      data: payload,
    );
    final data = response.data;
    if (data == null) {
      throw const ServerException('Aucune donnee session retournee.');
    }
    return RecordingSessionModel.fromJson(data);
  }

  @override
  Future<void> delete(String id) async {
    // Le backend n'a pas de route DELETE pour /recording-sessions
    // On ignore silencieusement
  }

  @override
  Future<void> clear() async {
    // Pas d'endpoint global.
  }

  @override
  Future<void> purgeTutorialSessions() async {
    // L'API ne gère pas les sessions de tutoriel.
  }
}
