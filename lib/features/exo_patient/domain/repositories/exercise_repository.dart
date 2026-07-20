import 'package:medicail/features/exo_patient/domain/entities/exercise.dart';

abstract interface class ExerciseRepository {
  Future<List<Exercise>> getAll();

  Future<Exercise?> getById(String id);
}
