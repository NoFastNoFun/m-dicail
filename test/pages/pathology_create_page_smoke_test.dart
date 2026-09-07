import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/pathology/domain/entities/pathology_domain.dart';
import 'package:medicail/pages/pathology_create_page.dart';

void main() {
  testWidgets('PathologyCreatePage builds and saves via dropdown', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    var createdName = '';
    PathologyDomain? createdDomain;

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => PathologyCreatePage(
            onCreate: (name, domain) async {
              createdName = name;
              createdDomain = domain;
            },
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('fr'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PathologyCreatePage), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<PathologyDomain>), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<PathologyDomain>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Neurologie').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Test patho');
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(PathologyCreatePage)),
    );
    await tester.tap(find.text(l10n.templateSaveCreate));
    await tester.pumpAndSettle();

    expect(createdName, 'Test patho');
    expect(createdDomain, PathologyDomain.neurology);
  });
}
