import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/auth/app_lock_controller.dart';
import 'package:medicail/core/auth/biometric_auth_service.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/screenshot/screen_protection.dart';
import 'package:medicail/core/storage/app_session_storage.dart';
import 'package:medicail/features/auth/presentation/notifier/auth_notifier.dart';
import 'package:medicail/widget/auth/app_lock_gate.dart';
import 'package:medicail/widget/auth/sensitive_route_privacy_overlay.dart';

class _FakeSessionStorage implements AppSessionStorage {
  @override
  Future<bool> hasCompletedOnboarding() async => true;

  @override
  Future<void> markOnboardingCompleted() async {}

  @override
  Future<String?> readRememberedEmail() async => null;

  @override
  Future<void> writeRememberedEmail(String? email) async {}

  @override
  Future<bool> readBiometricLockEnabled() async => false;

  @override
  Future<void> writeBiometricLockEnabled(bool enabled) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GoRouter router;

  setUp(() {
    router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('home')),
        ),
      ],
    );
    final auth = AuthNotifier();
    getIt
      ..registerSingleton<GoRouter>(router)
      ..registerSingleton<AuthNotifier>(auth)
      ..registerSingleton<AppLockController>(
        AppLockController(
          _FakeSessionStorage(),
          BiometricAuthService(),
          auth,
        ),
      )
      ..registerSingleton<ScreenProtectionController>(
        ScreenProtectionController(router),
      );
  });

  tearDown(() async {
    router.dispose();
    await getIt.reset();
  });

  testWidgets(
    'first frame wrapping the router navigator does not assert !_dirty',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          builder: (context, child) {
            return SensitiveRoutePrivacyOverlay(
              child: AppLockGate(child: child ?? const SizedBox.shrink()),
            );
          },
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('home'), findsOneWidget);
    },
  );
}
