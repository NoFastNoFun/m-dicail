import 'package:medicail/features/patient/domain/entities/patient.dart';

abstract class PatientRepository {
  Future<List<Patient>> getAll({String? query, bool archived = false});

  Future<Patient?> getById(String id);

  Future<Patient> save(Patient patient);

  Future<Patient> archive(String id);

  Future<Patient> unarchive(String id);

  Future<void> delete(String id);

  Future<void> clear();
}
