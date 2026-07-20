import 'package:medicail/features/exo_patient/domain/entities/exercise.dart';

final class ExerciseModel extends Exercise {
  const ExerciseModel({
    required super.id,
    required super.name,
    required super.description,
    super.category,
    super.instructions,
    super.mediaUrl,
  });

  factory ExerciseModel.fromEntity(Exercise exercise) {
    return ExerciseModel(
      id: exercise.id,
      name: exercise.name,
      description: exercise.description,
      category: exercise.category,
      instructions: exercise.instructions,
      mediaUrl: exercise.mediaUrl,
    );
  }

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String?,
      instructions: json['instructions'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'instructions': instructions,
      'mediaUrl': mediaUrl,
    };
  }
}
