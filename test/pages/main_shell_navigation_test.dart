import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/layout/main_shell_chrome.dart';
import 'package:medicail/core/router/app_routes.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_bloc.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_event.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_state.dart';
import 'package:medicail/pages/main_shell.dart';
import 'package:medicail/widget/layout/app_bottom_nav_pill.dart';
import 'package:mocktail/mocktail.dart';
import 'package:showcaseview/showcaseview.dart';

import '../support/load_test_fonts.dart';

class _TutorialBloc extends MockBloc<TutorialEvent, TutorialState>
    implements TutorialBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadTestFonts);

  for (final size in [
    const Size(320, 640),
    const Size(390, 844),
    const Size(844, 390),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('navigation stays anchored at $size with text scale $scale', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(size);
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        tester.view.viewPadding = const FakeViewPadding(bottom: 24);
        tester.view.padding = const FakeViewPadding(bottom: 24);
        addTearDown(() async {
          tester.view.resetDevicePixelRatio();
          tester.view.resetPhysicalSize();
          tester.view.resetViewPadding();
          tester.view.resetPadding();
          tester.view.resetViewInsets();
          await tester.binding.setSurfaceSize(null);
        });
        ShowcaseView.register();
        addTearDown(() => ShowcaseView.get().unregister());
        final tutorial = _TutorialBloc();
        when(() => tutorial.state).thenReturn(const TutorialCompleted());
        addTearDown(tutorial.close);
        final router = GoRouter(
          initialLocation: AppRoutes.home,
          routes: [
            ShellRoute(
              builder: (context, state, child) => MainShell(child: child),
              routes: [
                for (final route in [AppRoutes.home, AppRoutes.appointments])
                  GoRoute(
                    path: route,
                    builder: (context, state) => ListView(
                      key: ValueKey(route),
                      padding: MainShellScope.scrollPaddingOf(context),
                      children: List.generate(
                        25,
                        (index) => SizedBox(
                          height: 80,
                          child: Text('Consultation $index'),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          BlocProvider<TutorialBloc>.value(
            value: tutorial,
            child: MaterialApp.router(
              routerConfig: router,
              locale: const Locale('fr'),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final nav = find.byType(AppBottomNavPill);
        final fab = find.byType(FloatingActionButton);
        final navRect = tester.getRect(nav);
        final fabRect = tester.getRect(fab);
        final list = tester.widget<ListView>(
          find.byKey(const ValueKey(AppRoutes.home)),
        );
        final initialPadding = list.padding;

        await tester.drag(
          find.byKey(const ValueKey(AppRoutes.home)),
          const Offset(0, -240),
        );
        await tester.pumpAndSettle();
        expect(tester.getRect(nav), navRect);
        expect(tester.getRect(fab), fabRect);
        expect(
          tester
              .widget<ListView>(find.byKey(const ValueKey(AppRoutes.home)))
              .padding,
          initialPadding,
        );
        expect(find.text('Patients'), findsOneWidget);
        expect(find.text('Réglages'), findsOneWidget);

        await tester.tap(find.text('Agenda'));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.getRect(nav), navRect);
        await tester.pumpAndSettle();
        expect(tester.getRect(nav), navRect);
        expect(tester.getRect(fab), fabRect);

        await tester.tap(fab);
        await tester.pumpAndSettle();
        expect(tester.getRect(nav), navRect);
        expect(tester.getRect(fab), fabRect);
        await tester.tap(fab);
        await tester.pumpAndSettle();

        tester.view.viewInsets = const FakeViewPadding(bottom: 180);
        tester.view.padding = FakeViewPadding.zero;
        await tester.pumpAndSettle();
        expect(tester.getRect(nav), navRect);
        expect(tester.getRect(fab), fabRect);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
