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
  Future<List<Patient>> getAll({String? query}) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/patients',
      queryParameters: query != null && query.isNotEmpty
          ? {'query': query}
          : null,
    );
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
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/patients/$id',
      );
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
  Future<Patient> save(Patient patient) async {
    final model = PatientModel.fromEntity(patient);

    // The backend owns persisted ids. Numeric patient_* ids are local drafts.
    if (patient.id.isEmpty || _isFrontendGeneratedId(patient.id)) {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/patients',
        data: model.toApiJson(),
      );
      return PatientModel.fromJson(response.data ?? const <String, dynamic>{});
    } else {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '/patients/${patient.id}',
        data: model.toApiJson(),
      );
      return PatientModel.fromJson(response.data ?? const <String, dynamic>{});
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

  bool _isFrontendGeneratedId(String id) {
    return RegExp(r'^patient_\d+$').hasMatch(id);
  }
}
