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

@lazySingleton
class AppRouter {
  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
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

  void goRecord({String? patientId}) {
    if (patientId == null || patientId.isEmpty) {
      push(AppRoutes.record);
      return;
    }
    push(Uri(path: AppRoutes.record, queryParameters: {
      'patientId': patientId,
    }).toString());
  }

  void goPatients() => push(AppRoutes.patients);

  void goPatientDetail(String patientId) => push('/patients/$patientId');

  void goDebug() => push(AppRoutes.debug);
}
