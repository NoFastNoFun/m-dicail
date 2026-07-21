import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:medicail/core/network/api_client.dart';
import 'package:medicail/features/appointment/data/models/appointment_model.dart';
import 'package:medicail/features/appointment/domain/entities/appointment.dart';
import 'package:medicail/features/appointment/domain/repositories/appointment_repository.dart';

@injectable
class ApiAppointmentRepository implements AppointmentRepository {
  ApiAppointmentRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<Appointment>> getByRange({
    required DateTime from,
    required DateTime to,
  }) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/appointments',
      queryParameters: {
        'from': from.toUtc().toIso8601String(),
        'to': to.toUtc().toIso8601String(),
      },
    );
    final data = response.data;
    if (data == null) {
      return [];
    }
    return data
        .map((json) => AppointmentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Appointment?> getById(String id) async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>('/appointments/$id');
      final data = response.data;
      if (data == null) {
        return null;
      }
      return AppointmentModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<Appointment> save(Appointment appointment) async {
    final model = AppointmentModel.fromEntity(appointment);
    final payload = model.toJson()
      ..remove('id')
      ..remove('created_at')
      ..remove('updated_at');

    if (appointment.id.isEmpty) {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/appointments',
        data: payload,
      );
      final data = response.data;
      if (data == null) {
        throw const ServerException('Aucune donnee rendez-vous retournee.');
      }
      return AppointmentModel.fromJson(data);
    }

    final response = await _apiClient.put<Map<String, dynamic>>(
      '/appointments/${appointment.id}',
      data: payload,
    );
    final data = response.data;
    if (data == null) {
      throw const ServerException('Aucune donnee rendez-vous retournee.');
    }
    return AppointmentModel.fromJson(data);
  }

  @override
  Future<void> delete(String id) async {
    await _apiClient.delete<void>('/appointments/$id');
  }

  @override
  Future<void> clear() async {}
}
