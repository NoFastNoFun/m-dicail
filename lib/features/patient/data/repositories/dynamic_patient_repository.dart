import 'package:injectable/injectable.dart';
import 'package:medicail/core/network/auth_token_storage.dart';
import 'package:medicail/features/patient/data/repositories/api_patient_repository.dart';
import 'package:medicail/features/patient/data/repositories/secure_storage_patient_repository.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/patient/domain/repositories/patient_repository.dart';
import 'package:medicail/core/config/app_config.dart';

@LazySingleton(as: PatientRepository)
class DynamicPatientRepository implements PatientRepository {
  DynamicPatientRepository(
    this._apiRepository,
    this._localRepository,
    this._tokenStorage,
  );

  final ApiPatientRepository _apiRepository;
  final SecureStoragePatientRepository _localRepository;
  final AuthTokenStorage _tokenStorage;

  Future<PatientRepository> _getRepository() async {
    final token = await _tokenStorage.readToken();
    if (token == AppConfig.mockAdminToken) {
      return _localRepository;
    }
    return _apiRepository;
  }

  @override
  Future<List<Patient>> getAll({String? query}) async {
    final repo = await _getRepository();
    return repo.getAll(query: query);
  }

  @override
  Future<Patient?> getById(String id) async {
    final repo = await _getRepository();
    return repo.getById(id);
  }

  @override
  Future<Patient> save(Patient patient) async {
    final repo = await _getRepository();
    return repo.save(patient);
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
