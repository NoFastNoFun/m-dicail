import 'package:equatable/equatable.dart';
import 'package:medicail/features/note_template/domain/entities/note_section.dart';
import 'package:medicail/features/note_template/domain/entities/note_template_source.dart';

class NoteTemplate extends Equatable {
  const NoteTemplate({
    required this.id,
    required this.pathologyKey,
    required this.name,
    required this.sections,
    required this.source,
    this.parentTemplateId,
    this.updatedAt,
  });

  final String id;
  final String pathologyKey;
  final String name;
  final List<NoteSection> sections;
  final NoteTemplateSource source;
  final String? parentTemplateId;
  final DateTime? updatedAt;

  List<NoteSection> get orderedSections {
    final copy = List<NoteSection>.from(sections);
    copy.sort((a, b) => a.order.compareTo(b.order));
    return copy;
  }

  bool get isBuiltIn => source == NoteTemplateSource.builtIn;

  bool get isUserVariant => source == NoteTemplateSource.userVariant;

  NoteTemplate copyWith({
    String? id,
    String? pathologyKey,
    String? name,
    List<NoteSection>? sections,
    NoteTemplateSource? source,
    String? parentTemplateId,
    DateTime? updatedAt,
    bool clearParentTemplateId = false,
    bool clearUpdatedAt = false,
  }) {
    return NoteTemplate(
      id: id ?? this.id,
      pathologyKey: pathologyKey ?? this.pathologyKey,
      name: name ?? this.name,
      sections: sections ?? this.sections,
      source: source ?? this.source,
      parentTemplateId:
          clearParentTemplateId ? null : parentTemplateId ?? this.parentTemplateId,
      updatedAt: clearUpdatedAt ? null : updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        pathologyKey,
        name,
        sections,
        source,
        parentTemplateId,
        updatedAt,
      ];
}
