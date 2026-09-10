import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/router/app_routes.dart';
import 'package:medicail/core/screenshot/screen_protection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('dev.nf2.medicail/screen_protection');
  late List<bool> enabledCalls;

  setUp(() {
    enabledCalls = <bool>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'setEnabled') {
        final args = Map<String, dynamic>.from(call.arguments as Map);
        enabledCalls.add(args['enabled'] as bool);
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  GoRouter createRouter({String initialLocation = '/'}) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
        GoRoute(
          path: AppRoutes.home,
          builder: (_, _) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: AppRoutes.patients,
          builder: (_, _) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: AppRoutes.record,
          builder: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  test('isSensitiveRoute does not throw before the router has matches', () {
    final router = createRouter();
    addTearDown(router.dispose);
    final controller = ScreenProtectionController(router);

    expect(controller.isSensitiveRoute, isFalse);
  });

  test('start before router attach does not throw', () async {
    final router = createRouter();
    addTearDown(router.dispose);
    final controller = ScreenProtectionController(router);

    expect(() => controller.start(), returnsNormally);
    await controller.syncFromRoute();
    expect(controller.isEnabled, isFalse);
    controller.disposeController();
  });

  testWidgets('enables protection on patients after the router attaches', (
    tester,
  ) async {
    final router = createRouter(initialLocation: AppRoutes.patients);
    addTearDown(router.dispose);
    final controller = ScreenProtectionController(router);
    addTearDown(controller.disposeController);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();

    controller.start();
    await tester.pump();

    expect(controller.isSensitiveRoute, isTrue);
    expect(controller.isEnabled, isTrue);
    expect(enabledCalls, [true]);
  });

  test('isSensitiveLocation covers PHI routes', () {
    expect(ScreenProtectionController.isSensitiveLocation('/patients'), isTrue);
    expect(
      ScreenProtectionController.isSensitiveLocation('/patients/abc'),
      isTrue,
    );
    expect(ScreenProtectionController.isSensitiveLocation('/record'), isTrue);
    expect(ScreenProtectionController.isSensitiveLocation('/home'), isFalse);
  });
}
