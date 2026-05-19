import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/router/app_routes.dart';
import 'package:medicail/pages/debug_page.dart';
import 'package:medicail/pages/home_page.dart';
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
        builder: (context, state) => const RecordPage(),
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

  void goRecord() => push(AppRoutes.record);

  void goDebug() => push(AppRoutes.debug);
}
