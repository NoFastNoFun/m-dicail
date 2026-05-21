import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/router/app_routes.dart';
import 'package:medicail/pages/debug_page.dart';
import 'package:medicail/pages/home_page.dart';
import 'package:medicail/pages/patient_detail_page.dart';
import 'package:medicail/pages/patients_page.dart';
import 'package:medicail/pages/record_page.dart';
import 'package:medicail/widget/app_text.dart';

import 'package:medicail/features/auth/presentation/notifier/auth_notifier.dart';
import 'package:medicail/pages/login_page.dart';
import 'package:medicail/pages/register_page.dart';

@lazySingleton
class AppRouter {
  AppRouter(this._authNotifier);

  final AuthNotifier _authNotifier;

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: _authNotifier,
    redirect: (context, state) {
      final isAuth = _authNotifier.isAuthenticated;
      final isLoggingIn = state.uri.toString() == AppRoutes.login || 
                          state.uri.toString() == AppRoutes.register;

      if (!isAuth && !isLoggingIn) {
        return AppRoutes.login;
      }

      if (isAuth && isLoggingIn) {
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
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.record,
        name: 'record',
        builder: (context, state) => RecordPage(
          patientId: state.uri.queryParameters['patientId'],
        ),
      ),
      GoRoute(
        path: AppRoutes.patients,
        name: 'patients',
        builder: (context, state) => const PatientsPage(),
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

  void goPatients() => push(AppRoutes.patients);

  void goPatientDetail(String patientId) => push('/patients/$patientId');

  void goDebug() => push(AppRoutes.debug);
}
