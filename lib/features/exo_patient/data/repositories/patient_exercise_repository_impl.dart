import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/features/exo_patient/data/models/patient_exercise_model.dart';
import 'package:medicail/features/exo_patient/domain/entities/patient_exercise.dart';
import 'package:medicail/features/exo_patient/domain/entities/patient_exercise_status.dart';
import 'package:medicail/features/exo_patient/domain/repositories/patient_exercise_repository.dart';

@LazySingleton(as: PatientExerciseRepository)
class PatientExerciseRepositoryImpl implements PatientExerciseRepository {
  PatientExerciseRepositoryImpl(this._storage);

  static const String _storageKey = 'patient_exercises_v1';

  final FlutterSecureStorage _storage;

  @override
  Future<List<PatientExercise>> getForPatient(String patientId) async {
    final all = await _readAll();
    final forPatient = all
        .where((assignment) => assignment.patientId == patientId)
        .toList();
    forPatient.sort((a, b) => b.assignedAt.compareTo(a.assignedAt));
    return forPatient;
  }

  @override
  Future<PatientExercise> assign(PatientExercise assignment) async {
    final id = assignment.id.isEmpty
        ? 'patient_exercise_${DateTime.now().toUtc().microsecondsSinceEpoch}'
        : assignment.id;
    final saved = assignment.copyWith(id: id);

    final all = await _readAll();
    final next = <PatientExercise>[
      for (final current in all)
        if (current.id != id) current,
      saved,
    ];
    await _writeAll(next);
    return saved;
  }

  @override
  Future<PatientExercise> updateStatus({
    required String id,
    required PatientExerciseStatus status,
  }) async {
    final all = await _readAll();
    PatientExercise? existing;
    for (final assignment in all) {
      if (assignment.id == id) {
        existing = assignment;
        break;
      }
    }
    if (existing == null) {
      throw StateError('Assignment not found.');
    }

    final updated = existing.copyWith(status: status, updatedAt: DateTime.now());
    final next = <PatientExercise>[
      for (final current in all)
        if (current.id != id) current,
      updated,
    ];
    await _writeAll(next);
    return updated;
  }

  @override
  Future<void> unassign(String id) async {
    final all = await _readAll();
    final next = <PatientExercise>[
      for (final current in all)
        if (current.id != id) current,
    ];
    await _writeAll(next);
  }

  Future<List<PatientExercise>> _readAll() async {
    try {
      final raw = await _storage.read(key: _storageKey);
      if (raw == null || raw.isEmpty) {
        return const [];
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }

      return [
        for (final item in decoded)
          if (item is Map)
            PatientExerciseModel.fromJson(Map<String, dynamic>.from(item)),
      ];
    } catch (_) {
      try {
        await _storage.delete(key: _storageKey);
      } catch (_) {
        // Best effort cleanup when local assignments are corrupted.
      }
      return const [];
    }
  }

  Future<void> _writeAll(List<PatientExercise> assignments) {
    final encoded = jsonEncode(
      assignments
          .map(PatientExerciseModel.fromEntity)
          .map((assignment) => assignment.toJson())
          .toList(),
    );
    return _storage.write(key: _storageKey, value: encoded);
  }
}
