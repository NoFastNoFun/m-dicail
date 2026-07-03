import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/features/note_template/domain/entities/note_section.dart';
import 'package:medicail/features/note_template/domain/entities/note_section_kind.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/features/note_template/domain/entities/note_template_source.dart';
import 'package:medicail/features/note_template/domain/utils/note_template_applicator.dart';

void main() {
  group('NoteTemplateApplicator', () {
    test('uses default SOAP when template is null', () {
      final note = NoteTemplateApplicator.apply(
        template: null,
        transcript: '',
      );

      expect(note.subjective, contains('Motif de consultation'));
      expect(note.objective, contains('Examen clinique'));
    });

    test('merges transcript with subjective prompt', () {
      final template = NoteTemplate(
        id: 'test',
        pathologyKey: 'ankle_sprain',
        name: 'Entorse',
        source: NoteTemplateSource.builtIn,
        sections: const [
          NoteSection(
            id: 'subjective',
            kind: NoteSectionKind.subjective,
            title: 'Subjectif',
            prompt: '- EVA :',
            order: 0,
          ),
          NoteSection(
            id: 'objective',
            kind: NoteSectionKind.objective,
            title: 'Objectif',
            prompt: '- Examen :',
            order: 1,
          ),
          NoteSection(
            id: 'assessment',
            kind: NoteSectionKind.assessment,
            title: 'Evaluation',
            prompt: '- Hypothese :',
            order: 2,
          ),
          NoteSection(
            id: 'plan',
            kind: NoteSectionKind.plan,
            title: 'Plan',
            prompt: '- Suivi :',
            order: 3,
          ),
        ],
      );

      final note = NoteTemplateApplicator.apply(
        template: template,
        transcript: 'Douleur a la marche',
      );

      expect(note.subjective, contains('Douleur a la marche'));
      expect(note.subjective, contains('- EVA :'));
      expect(note.objective, contains('- Examen :'));
      expect(note.assessment, '- Hypothese :');
      expect(note.plan, '- Suivi :');
    });

    test('appends custom sections to objective and plan', () {
      final template = NoteTemplate(
        id: 'test',
        pathologyKey: 'low_back_pain',
        name: 'Lombalgie',
        source: NoteTemplateSource.builtIn,
        sections: const [
          NoteSection(
            id: 'subjective',
            kind: NoteSectionKind.subjective,
            title: 'Subjectif',
            prompt: '- Motif :',
            order: 0,
          ),
          NoteSection(
            id: 'objective',
            kind: NoteSectionKind.objective,
            title: 'Objectif',
            prompt: '- Palpation :',
            order: 1,
          ),
          NoteSection(
            id: 'assessment',
            kind: NoteSectionKind.assessment,
            title: 'Evaluation',
            prompt: '- Bilan :',
            order: 2,
          ),
          NoteSection(
            id: 'plan',
            kind: NoteSectionKind.plan,
            title: 'Plan',
            prompt: '- Exercices :',
            order: 3,
          ),
          NoteSection(
            id: 'custom_1',
            kind: NoteSectionKind.custom,
            title: 'Red flags',
            prompt: '- Fievre :',
            order: 4,
          ),
          NoteSection(
            id: 'custom_2',
            kind: NoteSectionKind.custom,
            title: 'EVA',
            prompt: '- EVA nuit :',
            order: 5,
          ),
        ],
      );

      final note = NoteTemplateApplicator.apply(
        template: template,
        transcript: '',
      );

      expect(note.objective, contains('## Red flags'));
      expect(note.objective, contains('- Fievre :'));
      expect(note.plan, contains('## EVA'));
      expect(note.plan, contains('- EVA nuit :'));
    });
  });
}
