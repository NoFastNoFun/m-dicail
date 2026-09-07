import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/widget/buttons/app_button.dart';
import 'package:medicail/widget/buttons/app_radial_action_button.dart';

void main() {
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

  testWidgets('AppButton shows label and triggers callback', (
    WidgetTester tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(label: 'Demarrer', onPressed: () => tapped = true),
        ),
      ),
    );

    expect(find.text('Demarrer'), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(tapped, isTrue);
    expect(haptics.single.arguments, 'HapticFeedbackType.lightImpact');
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
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(haptics, isEmpty);
  });

  testWidgets('loading button does not run its action or vibrate', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            label: 'Sauvegarder',
            isLoading: true,
            onPressed: () => taps++,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(taps, 0);
    expect(haptics, isEmpty);
  });

  testWidgets('unavailable native feedback never prevents the action', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            throw PlatformException(code: 'unavailable');
          }
          return null;
        });
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(label: 'Continuer', onPressed: () => tapped = true),
        ),
      ),
    );
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(tapped, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop buttons activate without native haptics', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(label: 'Continuer', onPressed: () => tapped = true),
        ),
      ),
    );
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(tapped, isTrue);
    expect(haptics, isEmpty);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets(
    'radial actions vibrate once per activation, not on outside dismissal',
    (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppRadialActionButton(
                actions: [
                  AppRadialAction(
                    icon: Icons.mic,
                    label: 'Enregistrer',
                    onTap: () => taps++,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(haptics, hasLength(1));
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(haptics, hasLength(2));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(haptics, hasLength(3));
    },
  );
}
