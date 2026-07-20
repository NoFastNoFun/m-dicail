import 'package:injectable/injectable.dart';
import 'package:medicail/features/exo_patient/data/models/exercise_model.dart';
import 'package:medicail/features/exo_patient/domain/entities/exercise.dart';

@lazySingleton
class ExerciseCatalogDataSource {
  static final List<Exercise> _catalog = [
    const ExerciseModel(
      id: 'ex_quad_isometrique',
      name: 'Contraction isometrique du quadriceps',
      description: 'Renforcement doux du quadriceps sans mouvement articulaire.',
      category: 'genou',
      instructions:
          'Jambe tendue, contracter le quadriceps 5 secondes, relacher. '
          'Repeter 10 fois, 3 series.',
    ),
    const ExerciseModel(
      id: 'ex_epaule_pendulaire',
      name: 'Exercice pendulaire de l epaule',
      description: 'Mobilisation passive de l epaule en decontraction.',
      category: 'epaule',
      instructions:
          'Penche en avant, laisser le bras pendre et decrire de petits '
          'cercles pendant 1 minute.',
    ),
    const ExerciseModel(
      id: 'ex_gainage_dos',
      name: 'Gainage dorsal',
      description: 'Renforcement de la sangle abdominale et lombaire.',
      category: 'dos',
      instructions: 'Position planche, maintenir 20 a 30 secondes, 3 series.',
    ),
  ];

  Future<List<Exercise>> loadCatalog() async {
    return List<Exercise>.from(_catalog);
  }
}
