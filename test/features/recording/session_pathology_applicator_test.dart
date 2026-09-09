import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/features/note_template/domain/entities/note_section.dart';
import 'package:medicail/features/note_template/domain/entities/note_section_kind.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/features/note_template/domain/entities/note_template_source.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/entities/session_pathology.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';
import 'package:medicail/features/recording/domain/utils/session_pathology_applicator.dart';

void main() {
  const soap = SoapNote(
    subjective: 'S IA',
    objective: 'O IA',
    assessment: 'A IA',
    plan: 'P IA',
  );
  const template = NoteTemplate(
    id: 'knee-template',
    pathologyKey: 'knee',
    name: 'Genou',
    source: NoteTemplateSource.builtIn,
    sections: [
      NoteSection(
        id: 'objective',
        kind: NoteSectionKind.objective,
        title: 'Examen',
        prompt: 'Mesurer la flexion',
        order: 0,
      ),
    ],
  );
  const tags = [
    SessionPathology(id: 'knee', name: 'Genou', templateId: 'knee-template'),
    SessionPathology(id: 'back', name: 'Dos'),
  ];
  RecordingSession session({bool transcriptIsAi = false}) => RecordingSession(
    id: 'test',
    startedAt: DateTime(2026),
    status: RecordingSessionStatus.completed,
    transcript: 'Transcription complète',
    transcriptIsAi: transcriptIsAi,
    soapNote: soap,
  );

  for (final transcriptIsAi in [true, false]) {
    test(
      'tagging preserves AI SOAP regardless of transcription source ($transcriptIsAi)',
      () {
        final result = SessionPathologyApplicator.apply(
          session: session(transcriptIsAi: transcriptIsAi),
          pathologies: tags,
          primaryTemplate: template,
        );
        expect(result.soapNote, same(soap));
        expect(result.pathologies, tags);
        expect(result.templateName, 'Genou');
        expect(result.transcript, 'Transcription complète');
      },
    );
  }

  test(
    'missing pathology template does not replace AI SOAP with a generic note',
    () {
      final result = SessionPathologyApplicator.apply(
        session: session(),
        pathologies: tags,
      );
      expect(result.soapNote, same(soap));
    },
  );

  test(
    'local SOAP still receives the pathology prefill even with AI transcription',
    () {
      final result = SessionPathologyApplicator.apply(
        session: session(transcriptIsAi: true),
        pathologies: tags,
        primaryTemplate: template,
        prefillLocalSoap: true,
      );
      expect(result.soapNote!.subjective, 'Transcription complète');
      expect(result.soapNote!.objective, 'Mesurer la flexion');
      expect(result.pathologies, tags);
    },
  );

  test('local SOAP without a template gets the existing generic prefill', () {
    final result = SessionPathologyApplicator.apply(
      session: session(),
      pathologies: tags,
      prefillLocalSoap: true,
    );
    expect(result.soapNote!.subjective, 'Transcription complète');
    expect(result.soapNote!.objective, contains('Examen clinique'));
  });
}
