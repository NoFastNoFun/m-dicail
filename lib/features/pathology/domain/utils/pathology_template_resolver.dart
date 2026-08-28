import 'package:injectable/injectable.dart';
import 'package:medicail/features/note_template/domain/entities/note_section.dart';
import 'package:medicail/features/note_template/domain/entities/note_section_kind.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/features/note_template/domain/entities/note_template_source.dart';
import 'package:medicail/features/note_template/domain/repositories/note_template_repository.dart';
import 'package:medicail/features/pathology/domain/entities/pathology.dart';

@lazySingleton
class PathologyTemplateResolver {
  PathologyTemplateResolver(this._templateRepository);

  final NoteTemplateRepository _templateRepository;

  Future<NoteTemplate?> resolveTemplate(Pathology pathology) async {
    final templateId = pathology.templateId;
    if (templateId == null || templateId.isEmpty) {
      return null;
    }
    return _templateRepository.getById(templateId);
  }

  NoteTemplate bareTemplateFor(Pathology pathology) {
    return NoteTemplate(
      id: pathology.templateId ?? pathology.id,
      pathologyId: pathology.id,
      pathologyKey: _slugify(pathology.name),
      name: pathology.name,
      sections: const [
        NoteSection(
          id: 'subjective',
          kind: NoteSectionKind.subjective,
          title: 'Subjectif',
          prompt: '',
          order: 0,
        ),
        NoteSection(
          id: 'objective',
          kind: NoteSectionKind.objective,
          title: 'Objectif',
          prompt: '',
          order: 1,
        ),
        NoteSection(
          id: 'assessment',
          kind: NoteSectionKind.assessment,
          title: 'Evaluation',
          prompt: '',
          order: 2,
        ),
        NoteSection(
          id: 'plan',
          kind: NoteSectionKind.plan,
          title: 'Plan',
          prompt: '',
          order: 3,
        ),
      ],
      source: pathology.isBuiltIn
          ? NoteTemplateSource.builtIn
          : NoteTemplateSource.userVariant,
    );
  }

  Future<NoteTemplate> resolveForSession(Pathology pathology) async {
    final existing = await resolveTemplate(pathology);
    if (existing != null) {
      return existing;
    }
    return bareTemplateFor(pathology);
  }

  String _slugify(String value) {
    final normalized = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    if (normalized.isEmpty) {
      return 'pathology';
    }
    return normalized;
  }
}
