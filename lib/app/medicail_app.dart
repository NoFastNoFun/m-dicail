import 'package:flutter/material.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/config/app_theme.dart';
import 'package:medicail/core/di/injection.dart';

class MedicailApp extends StatelessWidget {
  const MedicailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Medicail',
      theme: AppTheme.light,
      locale: const Locale('fr'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: getIt<GoRouter>(),
    );
  }
}
