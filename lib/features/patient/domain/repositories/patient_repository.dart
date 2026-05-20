import 'package:medicail/features/patient/domain/entities/patient.dart';

abstract class PatientRepository {
  Future<List<Patient>> getAll();

  Future<Patient?> getById(String id);

  Future<void> save(Patient patient);

  Future<void> delete(String id);

  Future<void> clear();
}
