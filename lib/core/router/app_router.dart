import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/router/app_routes.dart';
import 'package:medicail/pages/debug_page.dart';
import 'package:medicail/pages/home_page.dart';
import 'package:medicail/pages/main_shell.dart';
import 'package:medicail/pages/patient_detail_page.dart';
import 'package:medicail/pages/patients_page.dart';
import 'package:medicail/pages/record_page.dart';
import 'package:medicail/pages/settings_page.dart';
import 'package:medicail/widget/app_text.dart';

import 'package:medicail/features/auth/presentation/notifier/auth_notifier.dart';
import 'package:medicail/pages/login_page.dart';
import 'package:medicail/pages/register_page.dart';

@lazySingleton
class AppRouter {
  AppRouter(this._authNotifier);

  final AuthNotifier _authNotifier;

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: _authNotifier,
    redirect: (context, state) {
      final hasCompletedOnboarding = _authNotifier.hasCompletedOnboarding;
      final isAuthenticated = _authNotifier.isAuthenticated;
      final isAuthRoute = state.uri.toString() == AppRoutes.login ||
          state.uri.toString() == AppRoutes.register;

      if (!hasCompletedOnboarding && !isAuthRoute) {
        return AppRoutes.login;
      }

      if (isAuthenticated && isAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.patients,
            name: 'patients',
            builder: (context, state) => const PatientsPage(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.record,
        name: 'record',
        builder: (context, state) => RecordPage(
          patientId: state.uri.queryParameters['patientId'],
        ),
      ),
      GoRoute(
        path: AppRoutes.patientDetail,
        name: 'patient-detail',
        builder: (context, state) => PatientDetailPage(
          patientId: state.pathParameters['patientId'] ?? '',
        ),
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.debug,
          name: 'debug',
          builder: (context, state) => const DebugPage(),
        ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: AppText(
          'Route introuvable: ${state.uri}',
          variant: AppTextVariant.body,
        ),
      ),
    ),
  );
}

extension AppRouterNavigation on BuildContext {
  void goHome() => go(AppRoutes.home);

  Future<void> goRecord({String? patientId}) async {
    if (patientId == null || patientId.isEmpty) {
      await push(AppRoutes.record);
      return;
    }
    await push(Uri(path: AppRoutes.record, queryParameters: {
      'patientId': patientId,
    }).toString());
  }

  void goPatients() => go(AppRoutes.patients);

  void goSettings() => go(AppRoutes.settings);

  void goPatientDetail(String patientId) => push('/patients/$patientId');

  void goDebug() => push(AppRoutes.debug);
}
