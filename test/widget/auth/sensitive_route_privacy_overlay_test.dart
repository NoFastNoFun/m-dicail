import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/screenshot/screen_protection.dart';
import 'package:medicail/widget/auth/sensitive_route_privacy_overlay.dart';

class _FakeScreenProtection extends ScreenProtectionController {
  _FakeScreenProtection()
      : super(
          GoRouter(
            routes: [
              GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
            ],
          ),
        );

  final bool _enabledOverride = true;

  @override
  bool get isEnabled => _enabledOverride;
}

void main() {
  late _FakeScreenProtection protection;

  setUp(() {
    protection = _FakeScreenProtection();
    getIt.registerSingleton<ScreenProtectionController>(protection);
  });

  tearDown(() async {
    await getIt.reset();
  });

  Finder blackCover() => find.byWidgetPredicate(
        (widget) =>
            widget is ColoredBox && widget.color == const Color(0xFF000000),
      );

  testWidgets(
    'inactive does not paint black cover on Windows',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SensitiveRoutePrivacyOverlay(
            child: Scaffold(body: Text('content')),
          ),
        ),
      );

      expect(find.text('content'), findsOneWidget);
      expect(blackCover(), findsNothing);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();

      expect(blackCover(), findsNothing);
      expect(find.text('content'), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );

  testWidgets(
    'hidden still paints black cover on Windows when protection is on',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SensitiveRoutePrivacyOverlay(
            child: Scaffold(body: Text('content')),
          ),
        ),
      );

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await tester.pump();

      expect(blackCover(), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );

  testWidgets(
    'inactive paints black cover on Android when protection is on',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SensitiveRoutePrivacyOverlay(
            child: Scaffold(body: Text('content')),
          ),
        ),
      );

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();

      expect(blackCover(), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );
}
