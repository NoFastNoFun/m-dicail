import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:medicail/core/storage/secure_collection_store.dart';
import 'package:medicail/features/patient/data/models/patient_model.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/patient/domain/repositories/patient_repository.dart';

@injectable
class SecureStoragePatientRepository implements PatientRepository {
  SecureStoragePatientRepository(FlutterSecureStorage storage) {
    _store = SecureCollectionStore<Patient>(
      storage: storage,
      key: _patientsKey,
      fromJson: PatientModel.fromJson,
      toJson: (patient) => PatientModel.fromEntity(patient).toJson(),
    );
  }

  static const String _patientsKey = 'patients_v1';

  late final SecureCollectionStore<Patient> _store;

  @override
  Future<List<Patient>> getAll({String? query, bool archived = false}) async {
    final patients = await _store.readAll();
    final filtered = patients.where((p) => archived ? p.isArchived : !p.isArchived);
    if (query == null || query.isEmpty) {
      return filtered.toList();
    }
    final q = query.toLowerCase();
    return filtered.where((p) {
      return p.firstName.toLowerCase().contains(q) ||
          p.lastName.toLowerCase().contains(q) ||
          (p.mrn.toLowerCase().contains(q));
    }).toList();
  }

  @override
  Future<Patient?> getById(String id) async {
    final patients = await _store.readAll();
    for (final patient in patients) {
      if (patient.id == id) {
        return patient;
      }
    }
    return null;
  }

  @override
  Future<Patient> save(Patient patient) async {
    final now = DateTime.now();
    final savedPatient = patient.id.isEmpty
        ? patient.copyWith(
            id: 'patient_${now.toUtc().microsecondsSinceEpoch}',
            createdAt: now,
            updatedAt: now,
          )
        : patient.copyWith(updatedAt: now);

    await _store.mutate((patients) => <Patient>[
      for (final current in patients)
        if (current.id != savedPatient.id) current,
      savedPatient,
    ]..sort((a, b) => a.lastName.compareTo(b.lastName)));

    return savedPatient;
  }

  @override
  Future<Patient> archive(String id) async {
    final patient = await getById(id);
    if (patient == null) {
      throw const ServerException('Patient introuvable');
    }
    return save(patient.copyWith(archivedAt: DateTime.now()));
  }

  @override
  Future<Patient> unarchive(String id) async {
    final patient = await getById(id);
    if (patient == null) {
      throw const ServerException('Patient introuvable');
    }
    return save(patient.copyWith(clearArchivedAt: true));
  }

  @override
  Future<void> delete(String id) async {
    await _store.mutate(
      (patients) => [
        for (final patient in patients)
          if (patient.id != id) patient,
      ],
    );
  }

  @override
  Future<void> clear() => _store.clear();
}
