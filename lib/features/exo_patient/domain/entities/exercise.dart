import 'package:equatable/equatable.dart';

class Exercise extends Equatable {
  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    this.category,
    this.instructions,
    this.mediaUrl,
  });

  final String id;
  final String name;
  final String description;
  final String? category;
  final String? instructions;
  final String? mediaUrl;

  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? instructions,
    String? mediaUrl,
    bool clearCategory = false,
    bool clearInstructions = false,
    bool clearMediaUrl = false,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: clearCategory ? null : category ?? this.category,
      instructions: clearInstructions ? null : instructions ?? this.instructions,
      mediaUrl: clearMediaUrl ? null : mediaUrl ?? this.mediaUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        instructions,
        mediaUrl,
      ];
}
