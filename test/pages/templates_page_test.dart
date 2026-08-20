import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/note_template/domain/entities/note_section.dart';
import 'package:medicail/features/note_template/domain/entities/note_section_kind.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/features/note_template/domain/entities/note_template_source.dart';
import 'package:medicail/features/note_template/domain/repositories/note_template_repository.dart';
import 'package:medicail/features/note_template/presentation/note_template_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/pages/templates_page.dart';
import 'package:mocktail/mocktail.dart';

class _MockNoteTemplateRepository extends Mock implements NoteTemplateRepository {}

NoteTemplate _template(String id, String name) {
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
  late _MockNoteTemplateRepository repository;

  setUp(() {
    repository = _MockNoteTemplateRepository();
    if (GetIt.I.isRegistered<NoteTemplateBloc>()) {
      GetIt.I.unregister<NoteTemplateBloc>();
    }
    getIt.registerFactory<NoteTemplateBloc>(
      () => NoteTemplateBloc(repository),
    );
  });

  tearDown(() {
    if (GetIt.I.isRegistered<NoteTemplateBloc>()) {
      GetIt.I.unregister<NoteTemplateBloc>();
    }
  });

  Widget buildSubject() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const TemplatesPage(),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('fr'),
    );
  }

  testWidgets('TemplatesPage displays 10 default templates', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2400));

    final builtInTemplates = List<NoteTemplate>.generate(
      10,
      (index) => _template('builtin_$index', 'Pathologie $index'),
    );

    when(() => repository.getBuiltInTemplates())
        .thenAnswer((_) async => builtInTemplates);
    when(() => repository.getUserVariants()).thenAnswer((_) async => []);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.textContaining('Pathologie'), findsNWidgets(10));
    expect(find.text('Modeles par defaut'), findsOneWidget);
    expect(find.text('Creer un modele'), findsWidgets);

    addTearDown(() => tester.binding.setSurfaceSize(null));
  });
}
