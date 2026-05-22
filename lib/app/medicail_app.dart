import 'package:flutter/material.dart';
import 'package:medicail/core/config/app_theme.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_event.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_bloc.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_event.dart';
import 'package:medicail/widget/feedback/app_toast_host.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';

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
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
            ),
            BlocProvider<TutorialBloc>(
              create: (_) => getIt<TutorialBloc>()..add(const TutorialCheckRequested()),
            ),
          ],
          child: AppToastHost(
            child: ShowCaseWidget(
              builder: (context) => child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}
