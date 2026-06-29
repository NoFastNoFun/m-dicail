import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_event.dart';
import 'package:medicail/features/tutorial/domain/tutorial_flow.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_dialog.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_bloc.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_event.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_state.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_step_extensions.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_showcase_launcher.dart';
import 'package:showcaseview/showcaseview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _patientsKey = GlobalKey();
  final GlobalKey _recordKey = GlobalKey();
  bool _didAskTutorialStart = false;
  bool _didStartStepOneShowcase = false;
  bool _didStartStepNineShowcase = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _handleTutorialState(context.read<TutorialBloc>().state);
    });
  }

  void _handleTutorialState(TutorialState state) {
    if (state is TutorialInitial) {
      if (_didAskTutorialStart) return;
      _didAskTutorialStart = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showTutorialStartDialog();
      });
    } else if (state.isTutorialStep(TutorialStepId.homePatients)) {
      if (_didStartStepOneShowcase) return;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final started = await TutorialShowcaseLauncher.startWhenReady(
          context: context,
          key: _patientsKey,
        );
        if (started && mounted) {
          _didStartStepOneShowcase = true;
        }
      });
    } else if (state.isTutorialStep(TutorialStepId.homeQuickRecord)) {
      if (_didStartStepNineShowcase) return;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final started = await TutorialShowcaseLauncher.startWhenReady(
          context: context,
          key: _recordKey,
        );
        if (started && mounted) {
          _didStartStepNineShowcase = true;
        }
      });
    }
  }

  Future<void> _showTutorialStartDialog() async {
    final l10n = AppLocalizations.of(context);
    final shouldStart = await AppDialog.show<bool>(
      context,
      variant: AppDialogVariant.lockScreen,
      title: l10n.tutorialIntroTitle,
      body: AppText(l10n.tutorialIntroDesc, variant: AppTextVariant.body),
      actions: [
        AppButton(
          label: l10n.tutorialIntroSkip,
          style: AppButtonStyle.secondary,
          expanded: false,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton(
          label: l10n.tutorialIntroStart,
          expanded: false,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );

    if (!mounted) return;
    context.read<TutorialBloc>().add(
      shouldStart == true
          ? const TutorialStartRequested()
          : const TutorialSkipRequested(),
    );
  }

  void _openPatientsFromTutorial() {
    final tutorialBloc = context.read<TutorialBloc>();
    tutorialBloc.completeStep(TutorialStepId.homePatients);
    context.goPatients();
  }

  void _openRecordFromTutorial() {
    final tutorialBloc = context.read<TutorialBloc>();
    tutorialBloc.completeStep(TutorialStepId.homeQuickRecord);
    context.goRecord();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.homeTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocListener<TutorialBloc, TutorialState>(
            listener: (context, state) {
              _handleTutorialState(state);
            },
            child: const SizedBox.shrink(),
          ),
          AppText(l10n.labelHistory, variant: AppTextVariant.title),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: Center(
              child: AppText(l10n.historyEmpty, variant: AppTextVariant.body),
            ),
          ),
          Showcase(
            key: _patientsKey,
            title: l10n.tutorialHomePatientsTitle,
            description: l10n.tutorialHomePatientsDesc,
            disposeOnTap: true,
            onTargetClick: () {
              _openPatientsFromTutorial();
            },
            child: AppButton(
              label: l10n.navigateToPatients,
              onPressed: _openPatientsFromTutorial,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Showcase(
            key: _recordKey,
            title: l10n.tutorialHomeRecordTitle,
            description: l10n.tutorialHomeRecordDesc,
            disposeOnTap: true,
            onTargetClick: () {
              _openRecordFromTutorial();
            },
            child: AppButton(
              label: l10n.navigateToRecord,
              style: AppButtonStyle.secondary,
              onPressed: _openRecordFromTutorial,
            ),
          ),
        ],
      ),
    );
  }
}
