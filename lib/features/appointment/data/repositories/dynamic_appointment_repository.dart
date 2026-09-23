import 'package:injectable/injectable.dart';
import 'package:medicail/core/config/app_config.dart';
import 'package:medicail/core/network/auth_token_storage.dart';
import 'package:medicail/features/appointment/data/repositories/api_appointment_repository.dart';
import 'package:medicail/features/appointment/data/repositories/secure_storage_appointment_repository.dart';
import 'package:medicail/features/appointment/domain/entities/appointment.dart';
import 'package:medicail/features/appointment/domain/repositories/appointment_repository.dart';

@LazySingleton(as: AppointmentRepository)
class DynamicAppointmentRepository implements AppointmentRepository {
  DynamicAppointmentRepository(
    this._apiRepository,
    this._localRepository,
    this._tokenStorage,
  );

  final ApiAppointmentRepository _apiRepository;
  final SecureStorageAppointmentRepository _localRepository;
  final AuthTokenStorage _tokenStorage;

  Future<AppointmentRepository> _getRepository() async {
    final token = await _tokenStorage.readToken();
    if (AppConfig.isOfflineMode(token)) {
      return _localRepository;
    }
    return _apiRepository;
  }

  @override
  Future<List<Appointment>> getByRange({
    required DateTime from,
    required DateTime to,
  }) async {
    final repository = await _getRepository();
    return repository.getByRange(from: from, to: to);
  }

  @override
  Future<Appointment?> getById(String id) async {
    final repository = await _getRepository();
    return repository.getById(id);
  }

  @override
  Future<Appointment> save(Appointment appointment) async {
    final repository = await _getRepository();
    return repository.save(appointment);
  }

  @override
  Future<void> delete(String id) async {
    final repository = await _getRepository();
    await repository.delete(id);
  }

  @override
  Future<void> clear() async {
    final repository = await _getRepository();
    await repository.clear();
  }
}
