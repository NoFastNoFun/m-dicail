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

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppBottomNavPill(
              destinations: _destinations,
              selectedRoute: '/home',
              onDestinationSelected: (route) => selected = route,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Agenda'));
    await tester.pump();
    expect(selected, '/appointments');
  });

  testWidgets('swipe left on the pill selects the next destination', (
    tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppBottomNavPill(
              destinations: _destinations,
              selectedRoute: '/home',
              onDestinationSelected: (route) => selected = route,
            ),
          ),
        ),
      ),
    );

    await tester.fling(
      find.byType(AppBottomNavPill),
      const Offset(-120, 0),
      800,
    );
    await tester.pumpAndSettle();
    expect(selected, '/appointments');
  });

  testWidgets('swipe right on the pill selects the previous destination', (
    tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppBottomNavPill(
              destinations: _destinations,
              selectedRoute: '/appointments',
              onDestinationSelected: (route) => selected = route,
            ),
          ),
        ),
      ),
    );

    await tester.fling(
      find.byType(AppBottomNavPill),
      const Offset(120, 0),
      800,
    );
    await tester.pumpAndSettle();
    expect(selected, '/home');
  });

  testWidgets('swipe past the last tab does not change destination', (
    tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppBottomNavPill(
              destinations: _destinations,
              selectedRoute: '/settings',
              onDestinationSelected: (route) => selected = route,
            ),
          ),
        ),
      ),
    );

    await tester.fling(
      find.byType(AppBottomNavPill),
      const Offset(-120, 0),
      800,
    );
    await tester.pumpAndSettle();
    expect(selected, isNull);
  });
}
