import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicail/core/config/app_theme.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_event.dart';
import 'package:medicail/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:medicail/features/settings/presentation/bloc/settings_event.dart';
import 'package:medicail/features/settings/presentation/notifier/settings_notifier.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_bloc.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_event.dart';
import 'package:medicail/widget/feedback/app_toast_host.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';

class MedicailApp extends StatefulWidget {
  const MedicailApp({super.key});

  @override
  State<MedicailApp> createState() => _MedicailAppState();
}

class _MedicailAppState extends State<MedicailApp> {
  @override
  void initState() {
    super.initState();
    ShowcaseView.register(context);
  }

  @override
  void dispose() {
    ShowcaseView.unregister(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsNotifier = getIt<SettingsNotifier>();

    return ListenableBuilder(
      listenable: settingsNotifier,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Medicail',
          theme: AppTheme.forVariant(settingsNotifier.themeVariant),
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: getIt<GoRouter>(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(
                  settingsNotifier.fontScaleMultiplier,
                ),
              ),
              child: MultiBlocProvider(
                providers: [
                  BlocProvider<AuthBloc>(
                    create: (_) =>
                        getIt<AuthBloc>()..add(const AuthCheckRequested()),
                  ),
                  BlocProvider<SettingsBloc>(
                    create: (_) =>
                        getIt<SettingsBloc>()..add(const SettingsLoadRequested()),
                  ),
                  BlocProvider<TutorialBloc>(
                    create: (_) =>
                        getIt<TutorialBloc>()..add(const TutorialCheckRequested()),
                  ),
                ],
                child: AppToastHost(child: child ?? const SizedBox.shrink()),
              ),
            );
          },
        );
      },
    );
  }
}
