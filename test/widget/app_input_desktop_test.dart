import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/design_system/app_theme.dart';
import 'package:medicail/widget/inputs/app_input.dart';

void main() {
  testWidgets(
    'desktop number AppInput shows suffixText and stays compact in a Row',
    (tester) async {
      final previous = debugDefaultTargetPlatformOverride;
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      try {
        final hours = TextEditingController(text: '2');
        final minutes = TextEditingController(text: '30');
        addTearDown(hours.dispose);
        addTearDown(minutes.dispose);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: AppInput(
                        variant: AppInputVariant.number,
                        label: 'Heures',
                        controller: hours,
                        suffixText: 'h',
                        validator: (_) => null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppInput(
                        variant: AppInputVariant.number,
                        label: 'Minutes',
                        controller: minutes,
                        suffixText: 'min',
                        validator: (_) => null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('h'), findsOneWidget);
        expect(find.text('min'), findsOneWidget);
        expect(tester.takeException(), isNull);

        final hoursRect = tester.getRect(find.byType(TextFormField).at(0));
        final minutesRect = tester.getRect(find.byType(TextFormField).at(1));
        expect(hoursRect.height, lessThan(80));
        expect(minutesRect.height, lessThan(80));
        expect(hoursRect.right, lessThan(minutesRect.left));
      } finally {
        debugDefaultTargetPlatformOverride = previous;
      }
    },
  );

  testWidgets(
    'mobile number AppInput without suffixText does not show unit suffix',
    (tester) async {
      final previous = debugDefaultTargetPlatformOverride;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: AppInput(
                variant: AppInputVariant.number,
                label: 'Heures',
                validator: (_) => null,
              ),
            ),
          ),
        );

        expect(find.text('h'), findsNothing);
        expect(tester.takeException(), isNull);
      } finally {
        debugDefaultTargetPlatformOverride = previous;
      }
    },
  );
}
