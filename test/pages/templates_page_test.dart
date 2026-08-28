import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/pathology/domain/entities/pathology.dart';
import 'package:medicail/features/pathology/domain/entities/pathology_domain.dart';
import 'package:medicail/features/pathology/domain/entities/pathology_source.dart';
import 'package:medicail/features/pathology/domain/repositories/pathology_repository.dart';
import 'package:medicail/features/pathology/presentation/pathology_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/pages/templates_page.dart';
import 'package:mocktail/mocktail.dart';

class _MockPathologyRepository extends Mock implements PathologyRepository {}

Pathology _pathology(String id, String name) {
  return Pathology(
    id: id,
    name: name,
    domain: PathologyDomain.musculoskeletal,
    source: PathologySource.builtIn,
  );
}

void main() {
  late _MockPathologyRepository repository;

  setUp(() {
    repository = _MockPathologyRepository();
    if (GetIt.I.isRegistered<PathologyBloc>()) {
      GetIt.I.unregister<PathologyBloc>();
    }
    getIt.registerFactory<PathologyBloc>(() => PathologyBloc(repository));
    when(() => repository.ensureMigrated()).thenAnswer((_) async {});
  });

  tearDown(() {
    if (GetIt.I.isRegistered<PathologyBloc>()) {
      GetIt.I.unregister<PathologyBloc>();
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

  testWidgets('TemplatesPage displays default pathologies', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2400));

    final builtInPathologies = List<Pathology>.generate(
      10,
      (index) => _pathology('path_$index', 'Pathologie $index'),
    );

    when(() => repository.getBuiltInPathologies())
        .thenAnswer((_) async => builtInPathologies);
    when(() => repository.getUserPathologies()).thenAnswer((_) async => []);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Pathologie 0'), findsOneWidget);
    expect(find.text('Pathologie 9'), findsOneWidget);
    expect(find.text('Pathologies par defaut'), findsOneWidget);
    expect(find.text('Creer une pathologie'), findsWidgets);

    addTearDown(() => tester.binding.setSurfaceSize(null));
  });
}
