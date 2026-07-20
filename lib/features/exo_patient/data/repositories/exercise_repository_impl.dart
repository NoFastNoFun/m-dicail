import 'package:injectable/injectable.dart';
import 'package:medicail/features/exo_patient/data/datasources/exercise_catalog_data_source.dart';
import 'package:medicail/features/exo_patient/domain/entities/exercise.dart';
import 'package:medicail/features/exo_patient/domain/repositories/exercise_repository.dart';

@LazySingleton(as: ExerciseRepository)
class ExerciseRepositoryImpl implements ExerciseRepository {
  ExerciseRepositoryImpl(this._catalogDataSource);

  final ExerciseCatalogDataSource _catalogDataSource;

  @override
  Future<List<Exercise>> getAll() {
    return _catalogDataSource.loadCatalog();
  }

  @override
  Future<Exercise?> getById(String id) async {
    final catalog = await _catalogDataSource.loadCatalog();
    for (final exercise in catalog) {
      if (exercise.id == id) {
        return exercise;
      }
    }
    return null;
  }
}
