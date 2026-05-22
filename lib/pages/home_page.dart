import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_event.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_bloc.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_event.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_state.dart';
import 'package:showcaseview/showcaseview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _patientsKey = GlobalKey();
  final GlobalKey _recordKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.homeTitle,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            context.read<AuthBloc>().add(const AuthLogoutRequested());
          },
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocListener<TutorialBloc, TutorialState>(
            listener: (context, state) {
              if (state is TutorialInitial) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<TutorialBloc>().add(const TutorialStartRequested());
                });
              } else if (state is TutorialInProgress && state.currentStep == 1) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ShowCaseWidget.of(context).startShowCase([_patientsKey, _recordKey]);
                });
              }
            },
            child: const SizedBox.shrink(),
          ),
          AppText(l10n.labelHistory, variant: AppTextVariant.title),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: Center(
              child: AppText(
                l10n.historyEmpty,
                variant: AppTextVariant.body,
              ),
            ),
          ),
          Showcase(
            key: _patientsKey,
            title: l10n.tutorialHomePatientsTitle,
            description: l10n.tutorialHomePatientsDesc,
            disposeOnTap: true,
            onTargetClick: () {
              context.read<TutorialBloc>().add(const TutorialStepCompleted(1));
              context.goPatients();
            },
            child: AppButton(
              label: l10n.navigateToPatients,
              onPressed: () => context.goPatients(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Showcase(
            key: _recordKey,
            title: l10n.tutorialHomeRecordTitle,
            description: l10n.tutorialHomeRecordDesc,
            disposeOnTap: true,
            onTargetClick: () {
              context.read<TutorialBloc>().add(const TutorialStepCompleted(1));
              context.goRecord();
            },
            child: AppButton(
              label: l10n.navigateToRecord,
              style: AppButtonStyle.secondary,
              onPressed: () => context.goRecord(),
            ),
          ),
        ],
      ),
    );
  }
}
