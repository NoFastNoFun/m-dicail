import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/router/app_routes.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_bloc.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_event.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_state.dart';
import 'package:medicail/pages/main_shell.dart';
import 'package:mocktail/mocktail.dart';
import 'package:showcaseview/showcaseview.dart';

import '../support/load_test_fonts.dart';

class _TutorialBloc extends MockBloc<TutorialEvent, TutorialState>
    implements TutorialBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadTestFonts);

  late _TutorialBloc tutorial;
  late GoRouter router;

  setUp(() {
    ShowcaseView.register();
    tutorial = _TutorialBloc();
    when(() => tutorial.state).thenReturn(const TutorialCompleted());
    router = GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            for (final route in [
              AppRoutes.home,
              AppRoutes.appointments,
              AppRoutes.patients,
              AppRoutes.medicalWatch,
              AppRoutes.settings,
            ])
              GoRoute(
                path: route,
                builder: (context, state) => Text(
                  key: ValueKey(route),
                  route,
                ),
              ),
            GoRoute(
              path: AppRoutes.settingsProfile,
              builder: (context, state) => const Text(
                key: ValueKey(AppRoutes.settingsProfile),
                'profile',
              ),
            ),
          ],
        ),
      ],
    );
  });

  tearDown(() {
    tutorial.close();
    router.dispose();
    ShowcaseView.get().unregister();
  });

  Future<void> pumpShell(WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider<TutorialBloc>.value(
        value: tutorial,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapNavIcon(WidgetTester tester, IconData icon) async {
    await tester.tap(find.byIcon(icon));
    await tester.pumpAndSettle();
  }

  testWidgets('back from Patients returns to Home', (tester) async {
    await pumpShell(tester);
    await tapNavIcon(tester, Icons.folder_outlined);
    expect(find.byKey(const ValueKey(AppRoutes.patients)), findsOneWidget);

    final didPop = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(didPop, isTrue);
    expect(find.byKey(const ValueKey(AppRoutes.home)), findsOneWidget);
  });

  testWidgets('back walks tab history then reaches Home', (tester) async {
    await pumpShell(tester);
    await tapNavIcon(tester, Icons.folder_outlined);
    await tapNavIcon(tester, Icons.event_outlined);
    expect(find.byKey(const ValueKey(AppRoutes.appointments)), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey(AppRoutes.patients)), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey(AppRoutes.home)), findsOneWidget);
  });

  testWidgets('back on Home with empty history does not navigate away', (
    tester,
  ) async {
    await pumpShell(tester);
    expect(find.byKey(const ValueKey(AppRoutes.home)), findsOneWidget);

    final didPop = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(didPop, isFalse);
    expect(find.byKey(const ValueKey(AppRoutes.home)), findsOneWidget);
  });

  testWidgets('back pops pushed child before tab history', (tester) async {
    await pumpShell(tester);
    await tapNavIcon(tester, Icons.settings_outlined);
    expect(find.byKey(const ValueKey(AppRoutes.settings)), findsOneWidget);

    router.push(AppRoutes.settingsProfile);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey(AppRoutes.settingsProfile)),
      findsOneWidget,
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey(AppRoutes.settings)), findsOneWidget);
    expect(
      find.byKey(const ValueKey(AppRoutes.settingsProfile)),
      findsNothing,
    );
  });
}
