import 'package:medicail/features/exo_patient/domain/entities/patient_exercise.dart';
import 'package:medicail/features/exo_patient/domain/entities/patient_exercise_status.dart';

abstract interface class PatientExerciseRepository {
  Future<List<PatientExercise>> getForPatient(String patientId);

  Future<PatientExercise> assign(PatientExercise assignment);

  Future<PatientExercise> updateStatus({
    required String id,
    required PatientExerciseStatus status,
  });

  Future<void> unassign(String id);
}
