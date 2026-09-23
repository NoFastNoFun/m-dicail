import 'package:injectable/injectable.dart';
import 'package:medicail/core/network/auth_token_storage.dart';
import 'package:medicail/features/patient/data/repositories/api_patient_repository.dart';
import 'package:medicail/features/patient/data/repositories/secure_storage_patient_repository.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/patient/domain/repositories/patient_repository.dart';
import 'package:medicail/core/config/app_config.dart';
import 'package:medicail/features/tutorial/domain/tutorial_demo_patient.dart';
import 'package:medicail/features/tutorial/domain/tutorial_flow.dart';

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
    if (AppConfig.isOfflineMode(token)) {
      return _localRepository;
    }
    return _apiRepository;
  }

  @override
  Future<List<Patient>> getAll({String? query, bool archived = false}) async {
    final repository = await _getRepository();
    return repository.getAll(query: query, archived: archived);
  }

  @override
  Future<Patient?> getById(String id) async {
    if (id == TutorialFlow.demoPatientId) {
      return TutorialDemoPatient.patient;
    }
    final repository = await _getRepository();
    return repository.getById(id);
  }

  @override
  Future<Patient> save(Patient patient) async {
    if (patient.id == TutorialFlow.demoPatientId) {
      return TutorialDemoPatient.patient;
    }
    final repository = await _getRepository();
    return repository.save(patient);
  }

  @override
  Future<Patient> archive(String id) async {
    if (id == TutorialFlow.demoPatientId) {
      return TutorialDemoPatient.patient;
    }
    final repository = await _getRepository();
    return repository.archive(id);
  }

  @override
  Future<Patient> unarchive(String id) async {
    if (id == TutorialFlow.demoPatientId) {
      return TutorialDemoPatient.patient;
    }
    final repository = await _getRepository();
    return repository.unarchive(id);
  }

  @override
  Future<void> delete(String id) async {
    if (id == TutorialFlow.demoPatientId) {
      return;
    }
    final repository = await _getRepository();
    await repository.delete(id);
  }

  @override
  Future<void> clear() async {
    final repository = await _getRepository();
    await repository.clear();
  }
}
