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
  Future<void> save(RecordingSession session) async {
    final model = RecordingSessionModel.fromEntity(session);
    final payload = model.toJson()
      ..remove('id')
      ..remove('created_at')
      ..remove('updated_at');

    // Si l'id est vide ou généré en local (ne commence pas par recording_), c'est une création
    if (session.id.isEmpty || !session.id.startsWith('recording_')) {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/recording-sessions',
        data: payload,
      );
      final data = response.data;
      if (data == null) {
        throw const ServerException('Aucune donnee session retournee.');
      }
      return;
    }

    // Sinon mise a jour
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/recording-sessions/${session.id}',
      data: payload,
    );
    final data = response.data;
    if (data == null) {
      throw const ServerException('Aucune donnee session retournee.');
    }
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
}
