import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/widget/layout/app_bottom_nav_pill.dart';
import '../../support/load_test_fonts.dart';

const _frenchDestinations = [
  AppBottomNavDestination(
    route: '/home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    label: 'Accueil',
  ),
  AppBottomNavDestination(
    route: '/appointments',
    icon: Icons.event_outlined,
    selectedIcon: Icons.event,
    label: 'Agenda',
  ),
  AppBottomNavDestination(
    route: '/patients',
    icon: Icons.folder_outlined,
    selectedIcon: Icons.folder,
    label: 'Patients',
  ),
  AppBottomNavDestination(
    route: '/watch',
    icon: Icons.newspaper_outlined,
    selectedIcon: Icons.newspaper,
    label: 'News',
  ),
  AppBottomNavDestination(
    route: '/settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: 'Réglages',
  ),
];

const _destinations = [
  AppBottomNavDestination(
    route: '/home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    label: 'Home',
  ),
  AppBottomNavDestination(
    route: '/appointments',
    icon: Icons.event_outlined,
    selectedIcon: Icons.event,
    label: 'Agenda',
  ),
  AppBottomNavDestination(
    route: '/settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: 'Settings',
  ),
];

Future<void> _pumpPill(
  WidgetTester tester, {
  required String selectedRoute,
  required ValueChanged<String> onDestinationSelected,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: AppBottomNavPill(
            destinations: _destinations,
            selectedRoute: selectedRoute,
            onDestinationSelected: onDestinationSelected,
          ),
        ),
      ),
    ),
  );
}

Future<void> _dragBetweenLabels(
  WidgetTester tester, {
  required String from,
  required String to,
}) async {
  final start = tester.getCenter(find.text(from));
  final end = tester.getCenter(find.text(to));
  await tester.dragFrom(start, end - start);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadTestFonts);
  final haptics = <MethodCall>[];
  setUp(() {
    haptics.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') haptics.add(call);
          return null;
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  for (final width in [320.0, 360.0, 390.0, 600.0, 880.0]) {
    for (final textScale in [1.0, 1.3, 2.0]) {
      testWidgets('five labels fit at width $width and text scale $textScale', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(Size(width, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 800),
                  textScaler: TextScaler.linear(textScale),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: AppBottomNavPill(
                      destinations: _frenchDestinations,
                      selectedRoute: '/home',
                      onDestinationSelected: (_) {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        for (final destination in _frenchDestinations) {
          final richText = find.descendant(
            of: find.text(destination.label),
            matching: find.byType(RichText),
          );
          final paragraph = tester.renderObject<RenderParagraph>(richText);
          expect(
            paragraph.didExceedMaxLines,
            isFalse,
            reason: destination.label,
          );
        }
        final cells = find.descendant(
          of: find.byType(AppBottomNavPill),
          matching: find.byType(InkWell),
        );
        final firstSize = tester.getSize(cells.first);
        for (var i = 0; i < cells.evaluate().length; i++) {
          final size = tester.getSize(cells.at(i));
          expect(size.width, closeTo(firstSize.width, 0.01));
          expect(size.width, greaterThanOrEqualTo(48));
          expect(size.height, greaterThanOrEqualTo(48));
        }
      });
    }
  }
  test('indexOfBottomNavDestination matches nested routes', () {
    expect(indexOfBottomNavDestination(_destinations, '/home'), 0);
    expect(indexOfBottomNavDestination(_destinations, '/appointments'), 1);
    expect(
      indexOfBottomNavDestination(_destinations, '/settings/templates'),
      2,
    );
    expect(indexOfBottomNavDestination(_destinations, '/unknown'), -1);
  });

  testWidgets('tap still selects a destination', (tester) async {
    String? selected;

    await _pumpPill(
      tester,
      selectedRoute: '/home',
      onDestinationSelected: (route) => selected = route,
    );

    await tester.tap(find.text('Agenda'));
    await tester.pump();
    expect(selected, '/appointments');
    expect(haptics, hasLength(1));
  });

  testWidgets('dragging onto another destination selects it', (tester) async {
    String? selected;

    await _pumpPill(
      tester,
      selectedRoute: '/home',
      onDestinationSelected: (route) => selected = route,
    );

    await _dragBetweenLabels(tester, from: 'Home', to: 'Agenda');
    expect(selected, '/appointments');
    expect(haptics, hasLength(1));
  });

  testWidgets('dragging can skip destinations and land on the release target', (
    tester,
  ) async {
    String? selected;

    await _pumpPill(
      tester,
      selectedRoute: '/home',
      onDestinationSelected: (route) => selected = route,
    );

    await _dragBetweenLabels(tester, from: 'Home', to: 'Settings');
    expect(selected, '/settings');
  });

  testWidgets('dragging back onto a previous destination selects it', (
    tester,
  ) async {
    String? selected;

    await _pumpPill(
      tester,
      selectedRoute: '/settings',
      onDestinationSelected: (route) => selected = route,
    );

    await _dragBetweenLabels(tester, from: 'Settings', to: 'Agenda');
    expect(selected, '/appointments');
  });

  testWidgets('releasing on the current destination does not change it', (
    tester,
  ) async {
    String? selected;

    await _pumpPill(
      tester,
      selectedRoute: '/home',
      onDestinationSelected: (route) => selected = route,
    );

    await tester.drag(find.text('Home'), const Offset(28, 0));
    await tester.pumpAndSettle();
    expect(selected, isNull);
  });
}
