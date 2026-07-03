import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/features/note_template/data/datasources/asset_note_template_data_source.dart';
import 'package:medicail/features/note_template/domain/entities/note_section_kind.dart';
import 'package:medicail/features/note_template/domain/entities/note_template_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssetNoteTemplateDataSource', () {
    test('loads 10 built-in pathology templates', () async {
      final dataSource = AssetNoteTemplateDataSource();
      final templates = await dataSource.loadBuiltInTemplates();

      expect(templates, hasLength(10));
      expect(
        templates.every((template) => template.source == NoteTemplateSource.builtIn),
        isTrue,
      );

      final pathologyKeys = templates.map((template) => template.pathologyKey).toSet();
      expect(pathologyKeys, hasLength(10));
      expect(pathologyKeys, contains('ankle_sprain'));
      expect(pathologyKeys, contains('low_back_pain'));
      expect(pathologyKeys, contains('wrist_fracture'));
    });

    test('each template has SOAP and custom sections', () async {
      final templates = await AssetNoteTemplateDataSource().loadBuiltInTemplates();

      for (final template in templates) {
        final kinds = template.sections.map((section) => section.kind).toSet();
        expect(kinds, contains(NoteSectionKind.subjective));
        expect(kinds, contains(NoteSectionKind.objective));
        expect(kinds, contains(NoteSectionKind.assessment));
        expect(kinds, contains(NoteSectionKind.plan));
        expect(kinds, contains(NoteSectionKind.custom));
      }
    });
  });
}
