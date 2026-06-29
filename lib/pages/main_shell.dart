import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/core/router/app_routes.dart';
import 'package:medicail/features/tutorial/domain/tutorial_flow.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_bloc.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_event.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_showcase_launcher.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_state.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_step_extensions.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/buttons/app_radial_action_button.dart';
import 'package:medicail/widget/feedback/app_dialog.dart';
import 'package:medicail/widget/layout/app_bottom_nav_pill.dart';
import 'package:showcaseview/showcaseview.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const double _bottomOverlayHeight = 168;
  static const double _navLift = AppSpacing.lg;
  final _patientsNavKey = GlobalKey();
  final _quickRecordKey = GlobalKey();
  bool _didAskTutorialStart = false;
  bool _didStartPatientsShowcase = false;
  bool _didStartQuickRecordShowcase = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _handleTutorialState(context.read<TutorialBloc>().state);
    });
  }

  void _handleTutorialState(TutorialState state) {
    final stepId = state.tutorialStepId;
    if (state is TutorialInitial) {
      if (_didAskTutorialStart) return;
      _didAskTutorialStart = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showTutorialStartDialog();
      });
    } else if (stepId == TutorialStepId.homePatients) {
      if (_didStartPatientsShowcase) return;
      _startShowcase(_patientsNavKey, () => _didStartPatientsShowcase = true);
    } else if (stepId == TutorialStepId.homeQuickRecord) {
      if (_didStartQuickRecordShowcase) return;
      _startShowcase(_quickRecordKey, () => _didStartQuickRecordShowcase = true);
    }
  }

  void _startShowcase(GlobalKey key, VoidCallback markStarted) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final started = await TutorialShowcaseLauncher.startWhenReady(
        context: context,
        key: key,
      );
      if (started && mounted) {
        markStarted();
      }
    });
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
    context.read<TutorialBloc>().completeStep(TutorialStepId.homePatients);
    context.go(AppRoutes.patients);
  }

  void _openQuickRecordFromTutorial() {
    context.read<TutorialBloc>().completeStep(TutorialStepId.homeQuickRecord);
    context.goRecord();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final location = GoRouterState.of(context).matchedLocation;

    final destinations = [
      AppBottomNavDestination(
        route: AppRoutes.home,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: l10n.navHome,
      ),
      AppBottomNavDestination(
        route: AppRoutes.patients,
        icon: Icons.folder_outlined,
        selectedIcon: Icons.folder,
        label: l10n.navPatients,
        wrapper: (child) => Showcase(
          key: _patientsNavKey,
          title: l10n.tutorialHomePatientsTitle,
          description: l10n.tutorialHomePatientsDesc,
          disposeOnTap: true,
          onTargetClick: _openPatientsFromTutorial,
          child: child,
        ),
      ),
      AppBottomNavDestination(
        route: AppRoutes.settings,
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        label: l10n.navSettings,
      ),
    ];

    return BlocListener<TutorialBloc, TutorialState>(
      listener: (context, state) => _handleTutorialState(state),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(bottom: _bottomOverlayHeight),
                child: widget.child,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: _navLift,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.lg),
                        child: Showcase(
                          key: _quickRecordKey,
                          title: l10n.tutorialHomeRecordTitle,
                          description: l10n.tutorialHomeRecordDesc,
                          disposeOnTap: true,
                          onTargetClick: _openQuickRecordFromTutorial,
                          child: AppRadialActionButton(
                            anchor: AppRadialActionAnchor.end,
                            actions: [
                              AppRadialAction(
                                icon: Icons.folder_outlined,
                                label: l10n.radialActionPatients,
                                onTap: () => context.go(AppRoutes.patients),
                              ),
                              AppRadialAction(
                                icon: Icons.mic_outlined,
                                label: l10n.radialActionNewRecord,
                                onTap: () => context.goRecord(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Center(
                        child: AppBottomNavPill(
                          destinations: destinations,
                          selectedRoute: location,
                          onDestinationSelected: (route) => context.go(route),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
