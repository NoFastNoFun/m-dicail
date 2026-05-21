import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/network/api_client.dart';
import 'package:medicail/features/patient/data/models/patient_model.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/patient/domain/repositories/patient_repository.dart';

@injectable
class ApiPatientRepository implements PatientRepository {
  ApiPatientRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<Patient>> getAll() async {
    final response = await _apiClient.get<List<dynamic>>('/patients');
    final data = response.data;
    if (data == null) {
      return [];
    }
    return data
        .map((json) => PatientModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Patient?> getById(String id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('/patients/$id');
      final data = response.data;
      if (data == null) {
        return null;
      }
      return PatientModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<void> save(Patient patient) async {
    final model = PatientModel.fromEntity(patient);
    
    // Si l'ID est vide, c'est une création
    if (patient.id.isEmpty) {
      await _apiClient.post<Map<String, dynamic>>(
        '/patients',
        data: model.toJson()..remove('id'),
      );
    } else {
      // Sinon c'est une mise à jour (à adapter selon l'API si PUT existe, pour l'instant on garde save simple)
      await _apiClient.put<Map<String, dynamic>>(
        '/patients/${patient.id}',
        data: model.toJson(),
      );
    }
  }

  @override
  Future<void> delete(String id) async {
    await _apiClient.delete<void>('/patients/$id');
  }

  @override
  Future<void> clear() async {
    // API n'a pas d'endpoint global pour effacer tous les patients.
    // Ignoré ou lève une exception selon le besoin.
  }
}
