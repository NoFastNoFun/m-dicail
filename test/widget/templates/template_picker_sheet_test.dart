import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/note_template/domain/entities/note_section.dart';
import 'package:medicail/features/note_template/domain/entities/note_section_kind.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/features/note_template/domain/entities/note_template_source.dart';
import 'package:medicail/widget/templates/template_picker_sheet.dart';

NoteTemplate _builtIn(String id, String name) {
  return NoteTemplate(
    id: id,
    pathologyKey: id,
    name: name,
    source: NoteTemplateSource.builtIn,
    sections: const [
      NoteSection(
        id: 'subjective',
        kind: NoteSectionKind.subjective,
        title: 'Subjectif',
        prompt: '- Motif :',
        order: 0,
      ),
    ],
  );
}

void main() {
  testWidgets('TemplatePickerSheet lists built-in pathologies and returns tap',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    NoteTemplate? selected;
    final templates = [
      _builtIn('builtin_ankle_sprain', 'Entorse de cheville'),
      _builtIn('builtin_low_back_pain', 'Lombalgie'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('fr'),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  selected = await TemplatePickerSheet.show(
                    context,
                    templates: templates,
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Entorse de cheville'), findsOneWidget);
    expect(find.text('Lombalgie'), findsOneWidget);
    expect(find.text('Modeles par defaut'), findsOneWidget);

    await tester.tap(find.text('Lombalgie'));
    await tester.pumpAndSettle();

    expect(selected?.id, 'builtin_low_back_pain');
    expect(selected?.name, 'Lombalgie');
  });
}
