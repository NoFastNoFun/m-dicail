import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/widget/layout/app_bottom_nav_pill.dart';

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
