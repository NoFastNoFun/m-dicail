import 'package:medicail/features/note_template/domain/entities/note_section.dart';
import 'package:medicail/features/note_template/domain/entities/note_section_kind.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/features/note_template/domain/entities/note_template_source.dart';

final class NoteSectionModel extends NoteSection {
  const NoteSectionModel({
    required super.id,
    required super.kind,
    required super.title,
    required super.prompt,
    required super.order,
  });

  factory NoteSectionModel.fromEntity(NoteSection section) {
    return NoteSectionModel(
      id: section.id,
      kind: section.kind,
      title: section.title,
      prompt: section.prompt,
      order: section.order,
    );
  }

  factory NoteSectionModel.fromJson(Map<String, dynamic> json) {
    return NoteSectionModel(
      id: json['id'] as String,
      kind: NoteSectionKindX.fromJson(json['kind'] as String?),
      title: json['title'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kind': kind.jsonValue,
      'title': title,
      'prompt': prompt,
      'order': order,
    };
  }
}

final class NoteTemplateModel extends NoteTemplate {
  const NoteTemplateModel({
    required super.id,
    required super.pathologyKey,
    required super.name,
    required super.sections,
    required super.source,
    super.pathologyId,
    super.parentTemplateId,
    super.updatedAt,
  });

  factory NoteTemplateModel.fromEntity(NoteTemplate template) {
    return NoteTemplateModel(
      id: template.id,
      pathologyKey: template.pathologyKey,
      name: template.name,
      sections: template.sections,
      source: template.source,
      pathologyId: template.pathologyId,
      parentTemplateId: template.parentTemplateId,
      updatedAt: template.updatedAt,
    );
  }

  factory NoteTemplateModel.fromJson(Map<String, dynamic> json) {
    final sectionsJson = json['sections'];
    final sections = <NoteSection>[];
    if (sectionsJson is List) {
      for (final item in sectionsJson) {
        if (item is Map) {
          sections.add(
            NoteSectionModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return NoteTemplateModel(
      id: json['id'] as String,
      pathologyKey: json['pathologyKey'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sections: sections,
      source: NoteTemplateSourceX.fromJson(json['source'] as String?),
      pathologyId: json['pathologyId'] as String?,
      parentTemplateId: json['parentTemplateId'] as String?,
      updatedAt: _parseNullableDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pathologyKey': pathologyKey,
      'name': name,
      'sections': sections
          .map((section) => NoteSectionModel.fromEntity(section).toJson())
          .toList(),
      'source': source.jsonValue,
      'pathologyId': pathologyId,
      'parentTemplateId': parentTemplateId,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static DateTime? _parseNullableDate(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.parse(value);
  }
}
