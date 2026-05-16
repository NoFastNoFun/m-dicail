import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/router/app_routes.dart';
import 'package:medicail/pages/home_page.dart';
import 'package:medicail/pages/record_page.dart';

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
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route introuvable: ${state.uri}')),
    ),
  );
}

extension AppRouterNavigation on BuildContext {
  void goHome() => go(AppRoutes.home);

  void goRecord() => push(AppRoutes.record);
}
