import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/router/app_routes.dart';
import 'package:medicail/pages/debug_page.dart';
import 'package:medicail/pages/home_page.dart';
import 'package:medicail/pages/appointments_day_page.dart';
import 'package:medicail/pages/main_shell.dart';
import 'package:medicail/pages/patient_detail_page.dart';
import 'package:medicail/pages/patients_page.dart';
import 'package:medicail/pages/record_page.dart';
import 'package:medicail/pages/settings_page.dart';
import 'package:medicail/pages/medical_watch_page.dart';
import 'package:medicail/pages/template_editor_page.dart';
import 'package:medicail/pages/templates_page.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/core/i18n/app_localizations.dart';

import 'package:medicail/features/auth/presentation/notifier/auth_notifier.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_state.dart';
import 'package:medicail/pages/login_page.dart';
import 'package:medicail/pages/register_page.dart';
import 'package:medicail/pages/forgot_password_page.dart';
import 'package:medicail/pages/reset_password_page.dart';
import 'package:medicail/pages/recovery_page.dart';
import 'package:medicail/pages/mfa_login_page.dart';
import 'package:medicail/pages/security_settings_page.dart';

@lazySingleton
class AppRouter {
  AppRouter(this._authNotifier);

  final AuthNotifier _authNotifier;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  late final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.home,
    refreshListenable: _authNotifier,
    redirect: (context, state) {
      final location = state.uri.toString();
      final hasCompletedOnboarding = _authNotifier.hasCompletedOnboarding;
      final isAuthenticated = _authNotifier.isAuthenticated;
      final isAuthRoute = _isPublicAuthRoute(location);

      if (_authNotifier.hasCompletedOnboarding &&
          !_authNotifier.canAccessApp &&
          !isAuthRoute) {
        return AppRoutes.login;
      }

      if (!hasCompletedOnboarding && !isAuthRoute) {
        return AppRoutes.login;
      }

      if (isAuthenticated && (location == AppRoutes.login || location == AppRoutes.register)) {
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
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) {
          final email = state.extra is String ? state.extra as String : null;
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: ForgotPasswordPage(initialEmail: email),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => ResetPasswordPage(
          token: state.uri.queryParameters['token'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.recovery,
        builder: (context, state) => RecoveryPage(
          token: state.uri.queryParameters['token'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.loginMfa,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is AuthMfaRequired) {
            return MfaLoginPage(
              mfaToken: extra.mfaToken,
              methods: extra.methods,
              email: extra.email,
            );
          }
          return const LoginPage();
        },
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
            path: AppRoutes.appointments,
            name: 'appointments',
            builder: (context, state) {
              final dateParam = state.uri.queryParameters['date'];
              DateTime? initialDate;
              if (dateParam != null && dateParam.isNotEmpty) {
                initialDate = DateTime.tryParse(dateParam);
              }
              return AppointmentsDayPage(initialDate: initialDate);
            },
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
          GoRoute(
            path: AppRoutes.settingsSecurity,
            builder: (context, state) => const SecuritySettingsPage(),
          ),
          GoRoute(
            path: AppRoutes.medicalWatch,
            builder: (context, state) => const MedicalWatchPage(),
          ),
          GoRoute(
            path: AppRoutes.settingsTemplates,
            name: 'settings-templates',
            builder: (context, state) => const TemplatesPage(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'template-create',
                builder: (context, state) => TemplateEditorPage(
                  templateId: 'new',
                  isCreating: true,
                  pathologyId: state.uri.queryParameters['pathologyId'],
                ),
              ),
              GoRoute(
                path: ':templateId/edit',
                name: 'template-editor',
                builder: (context, state) => TemplateEditorPage(
                  templateId: state.pathParameters['templateId'] ?? '',
                  initialTemplate: state.extra is NoteTemplate
                      ? state.extra! as NoteTemplate
                      : null,
                ),
              ),
            ],
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
          '${AppLocalizations.of(context).routerErrorNotFound} ${state.uri}',
          variant: AppTextVariant.body,
        ),
      ),
    ),
  );

  bool _isPublicAuthRoute(String location) {
    return location == AppRoutes.login ||
        location == AppRoutes.register ||
        location.startsWith(AppRoutes.forgotPassword) ||
        location.startsWith(AppRoutes.resetPassword) ||
        location.startsWith(AppRoutes.recovery) ||
        location.startsWith(AppRoutes.loginMfa);
  }
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

  void goAppointments({DateTime? date}) {
    if (date == null) {
      push(AppRoutes.appointments);
      return;
    }
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    push(Uri(
      path: AppRoutes.appointments,
      queryParameters: {'date': '$y-$m-$d'},
    ).toString());
  }

  void goSettings() => go(AppRoutes.settings);

  void goTemplates() => pushNamed('settings-templates');

  void goPatientDetail(String patientId) => push('/patients/$patientId');

  void goDebug() => push(AppRoutes.debug);
}
