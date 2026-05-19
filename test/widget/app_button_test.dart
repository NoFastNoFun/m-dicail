import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/widget/buttons/app_button.dart';

void main() {
  testWidgets('AppButton shows label and triggers callback', (
    WidgetTester tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            label: 'Demarrer',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Demarrer'), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('AppButton shows loading indicator', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppButton(
            label: 'Chargement',
            onPressed: null,
            isLoading: true,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('AppButton icon layout is disabled when enabled is false', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            layout: AppButtonLayout.icon,
            icon: Icons.add,
            enabled: false,
            onPressed: () {},
          ),
        ),
      ),
    );

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });
}
