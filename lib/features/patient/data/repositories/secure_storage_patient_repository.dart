import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/features/patient/data/models/patient_model.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/patient/domain/repositories/patient_repository.dart';

@injectable
class SecureStoragePatientRepository implements PatientRepository {
  const SecureStoragePatientRepository(this._storage);

  static const String _patientsKey = 'patients_v1';

  final FlutterSecureStorage _storage;

  @override
  Future<List<Patient>> getAll() async {
    return _readPatients();
  }

  @override
  Future<Patient?> getById(String id) async {
    final patients = await _readPatients();
    for (final patient in patients) {
      if (patient.id == id) {
        return patient;
      }
    }
    return null;
  }

  @override
  Future<void> save(Patient patient) async {
    final patients = await _readPatients();
    final nextPatients = <Patient>[
      for (final current in patients)
        if (current.id != patient.id) current,
      patient,
    ]..sort((a, b) => a.lastName.compareTo(b.lastName));

    await _writePatients(nextPatients);
  }

  @override
  Future<void> delete(String id) async {
    final patients = await _readPatients();
    final nextPatients = [
      for (final patient in patients)
        if (patient.id != id) patient,
    ];
    await _writePatients(nextPatients);
  }

  @override
  Future<void> clear() => _storage.delete(key: _patientsKey);

  Future<List<Patient>> _readPatients() async {
    final raw = await _storage.read(key: _patientsKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map>()
        .map((json) => Map<String, dynamic>.from(json))
        .map(PatientModel.fromJson)
        .toList()
      ..sort((a, b) => a.lastName.compareTo(b.lastName));
  }

  Future<void> _writePatients(List<Patient> patients) {
    final encoded = jsonEncode(
      patients
          .map(PatientModel.fromEntity)
          .map((patient) => patient.toJson())
          .toList(),
    );
    return _storage.write(key: _patientsKey, value: encoded);
  }
}
