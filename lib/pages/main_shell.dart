import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/layout/app_breakpoints.dart';
import 'package:medicail/core/layout/main_shell_chrome.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/core/router/app_routes.dart';
import 'package:medicail/features/tutorial/domain/tutorial_flow.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_bloc.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_event.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_showcase_launcher.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_state.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_step_extensions.dart';
import 'package:medicail/widget/buttons/app_button.dart';
import 'package:medicail/widget/buttons/app_radial_action_button.dart';
import 'package:medicail/widget/appointment_form_sheet.dart';
import 'package:medicail/widget/feedback/app_dialog.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/layout/app_bottom_nav_pill.dart';
import 'package:medicail/widget/layout/app_side_nav_rail.dart';
import 'package:medicail/widget/layout/app_tab_slide_switcher.dart';
import 'package:medicail/widget/feedback/app_showcase.dart';
import 'package:showcaseview/showcaseview.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static EdgeInsets scrollPadding(BuildContext context) {
    return MainShellScope.maybeOf(context)?.scrollPadding(context) ??
        EdgeInsets.zero;
  }

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _patientsNavKey = GlobalKey();
  final _quickRecordKey = GlobalKey();
  final _addPatientFabKey = GlobalKey();

  bool _didAskTutorialStart = false;
  bool _didStartPatientsShowcase = false;
  bool _didStartQuickRecordShowcase = false;
  bool _didStartPatientsAddShowcase = false;
  String? _lastLocation;
  bool _navLabelsVisible = true;
  VoidCallback? _fabPrimaryAction;

  int? _lastSeenTutorialStep;

  void _registerFabPrimaryAction(VoidCallback? action) {
    if (_fabPrimaryAction == action) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _fabPrimaryAction = action);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _handleTutorialState(context.read<TutorialBloc>().state);
    });
  }

  void _handleTutorialState(TutorialState state) {
    if (state is TutorialLoading) {
      return;
    }

    if (state is TutorialInitial) {
      _didStartPatientsShowcase = false;
      _didStartQuickRecordShowcase = false;
      _didStartPatientsAddShowcase = false;
      _lastSeenTutorialStep = null;

      if (!_didAskTutorialStart) {
        _didAskTutorialStart = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (context.read<TutorialBloc>().state is! TutorialInitial) {
            return;
          }
          final l10n = AppLocalizations.of(context);
          AppDialog.show(
            context,
            variant: AppDialogVariant.lockScreen,
            title: l10n.tutorialIntroTitle,
            body: AppText(l10n.tutorialIntroDesc, variant: AppTextVariant.body),
            actionsBuilder: (dialogContext) => [
              AppButton(
                label: l10n.tutorialIntroSkip,
                style: AppButtonStyle.secondary,
                expanded: false,
                onPressed: () {
                  context.read<TutorialBloc>().add(
                    const TutorialSkipRequested(),
                  );
                  Navigator.of(dialogContext).pop();
                },
              ),
              AppButton(
                label: l10n.tutorialIntroStart,
                expanded: false,
                onPressed: () {
                  context.read<TutorialBloc>().add(
                    const TutorialStartRequested(),
                  );
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          );
        });
      }
      return;
    }

    if (state is! TutorialInProgress) {
      _didStartPatientsShowcase = false;
      _didStartQuickRecordShowcase = false;
      _didStartPatientsAddShowcase = false;
      _lastSeenTutorialStep = null;
      return;
    }

    if (_lastSeenTutorialStep != state.currentStep) {
      if (state.currentStep ==
          TutorialFlow.indexOf(TutorialStepId.homePatients)) {
        _didStartPatientsShowcase = false;
        _didStartQuickRecordShowcase = false;
        _didStartPatientsAddShowcase = false;
      }
      _lastSeenTutorialStep = state.currentStep;
      if (mounted) {
        setState(() {});
      }
    }

    final currentStep = TutorialFlow.idFromIndex(state.currentStep);
    final location = GoRouterState.of(context).matchedLocation;

    if (currentStep == TutorialStepId.homePatients &&
        !_didStartPatientsShowcase) {
      TutorialShowcaseLauncher.startWhenReady(
        context: context,
        key: _patientsNavKey,
      ).then((started) {
        if (mounted && started) {
          _didStartPatientsShowcase = true;
        }
      });
    }

    if (currentStep == TutorialStepId.patientsAdd &&
        location == AppRoutes.patients &&
        !_didStartPatientsAddShowcase) {
      TutorialShowcaseLauncher.startWhenReady(
        context: context,
        key: _addPatientFabKey,
      ).then((started) {
        if (mounted && started) {
          _didStartPatientsAddShowcase = true;
        }
      });
    }

    if (currentStep == TutorialStepId.homeQuickRecord) {
      if (location != AppRoutes.home) {
        _didStartQuickRecordShowcase = false;
        return;
      }
      if (!_didStartQuickRecordShowcase) {
        TutorialShowcaseLauncher.startWhenReady(
          context: context,
          key: _quickRecordKey,
        ).then((started) {
          if (mounted && started) {
            _didStartQuickRecordShowcase = true;
          }
        });
      }
    }
  }

  Future<void> _handleHomeQuickRecordTutorialTap() async {
    final tutorialBloc = context.read<TutorialBloc>();
    if (!tutorialBloc.isCurrentStep(TutorialStepId.homeQuickRecord)) {
      return;
    }
    ShowcaseView.get().dismiss();
    await tutorialBloc.completeHomeQuickRecordTutorial();
  }

  void _openQuickRecordIfAllowed() {
    final tutorialBloc = context.read<TutorialBloc>();
    if (!tutorialBloc.canOpenQuickRecordDuringTutorial) {
      return;
    }
    context.goRecord();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification ||
        notification is ScrollEndNotification) {
      final metrics = notification.metrics;
      if (!metrics.hasPixels) {
        return false;
      }

      final atTop = metrics.pixels <= metrics.minScrollExtent + 8;
      if (atTop != _navLabelsVisible) {
        setState(() => _navLabelsVisible = atTop);
      }
    }

    return false;
  }

  void _resetNavLabels() {
    if (!_navLabelsVisible) {
      setState(() => _navLabelsVisible = true);
    }
  }

  void _scheduleNavLabelReset() {
    if (_navLabelsVisible) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _resetNavLabels();
    });
  }

  void _onDestinationSelected(String route) {
    if (route == AppRoutes.patients) {
      final tutorialBloc = context.read<TutorialBloc>();
      if (tutorialBloc.state is TutorialInProgress &&
          TutorialFlow.idFromIndex(
                (tutorialBloc.state as TutorialInProgress).currentStep,
              ) ==
              TutorialStepId.homePatients) {
        tutorialBloc.add(
          TutorialStepCompleted(
            TutorialFlow.indexOf(TutorialStepId.homePatients),
          ),
        );
      }
    }
    context.go(route);
  }

  List<AppBottomNavDestination> _destinations(AppLocalizations l10n) {
    return [
      AppBottomNavDestination(
        route: AppRoutes.home,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: l10n.homeTitle,
      ),
      AppBottomNavDestination(
        route: AppRoutes.appointments,
        icon: Icons.event_outlined,
        selectedIcon: Icons.event,
        label: l10n.appointmentsDayTitle,
      ),
      AppBottomNavDestination(
        route: AppRoutes.patients,
        icon: Icons.folder_outlined,
        selectedIcon: Icons.folder,
        label: l10n.patientsTitle,
        wrapper: (child) => AppShowcase(
          key: _patientsNavKey,
          title: l10n.tutorialHomePatientsTitle,
          description: l10n.tutorialHomePatientsDesc,
          disposeOnTap: false,
          disableBarrierInteraction: true,
          onTargetClick: () {
            context.read<TutorialBloc>().add(
              TutorialStepCompleted(
                TutorialFlow.indexOf(TutorialStepId.homePatients),
              ),
            );
            context.go(AppRoutes.patients);
          },
          child: child,
        ),
      ),
      AppBottomNavDestination(
        route: AppRoutes.medicalWatch,
        icon: Icons.newspaper_outlined,
        selectedIcon: Icons.newspaper,
        label: l10n.medicalWatchNavTitle,
      ),
      AppBottomNavDestination(
        route: AppRoutes.settings,
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        label: l10n.settingsTitle,
      ),
    ];
  }

  Future<void> _handlePatientsAddTutorialTap() async {
    final tutorialBloc = context.read<TutorialBloc>();
    if (!tutorialBloc.isCurrentStep(TutorialStepId.patientsAdd)) {
      return;
    }
    ShowcaseView.get().dismiss();
    tutorialBloc.completeStep(TutorialStepId.patientsAdd);
    _fabPrimaryAction?.call();
  }

  Widget _buildQuickRecordFab(AppLocalizations l10n) {
    final location = GoRouterState.of(context).matchedLocation;
    final tutorialState = context.read<TutorialBloc>().state;
    final showPatientsAddShowcase =
        location == AppRoutes.patients &&
        tutorialState.isTutorialStep(TutorialStepId.patientsAdd);

    final button = AppRadialActionButton(
      anchor: AppRadialActionAnchor.end,
      onPrimaryPressed: _fabPrimaryAction,
      actions: [
        AppRadialAction(
          icon: Icons.event_outlined,
          label: l10n.appointmentCreateTitle,
          onTap: () =>
              AppointmentFormSheet.show(context, initialDay: DateTime.now()),
        ),
        AppRadialAction(
          icon: Icons.folder_outlined,
          label: l10n.patientsSectionTitle,
          onTap: () => context.go(AppRoutes.patients),
        ),
        AppRadialAction(
          icon: Icons.mic_outlined,
          label: l10n.radialActionNewRecord,
          onTap: () async {
            final tutorialBloc = context.read<TutorialBloc>();
            if (tutorialBloc.isCurrentStep(TutorialStepId.homeQuickRecord)) {
              await _handleHomeQuickRecordTutorialTap();
              return;
            }
            _openQuickRecordIfAllowed();
          },
        ),
      ],
    );

    if (showPatientsAddShowcase) {
      return AppShowcase(
        key: _addPatientFabKey,
        title: l10n.tutorialPatientAddTitle,
        description: l10n.tutorialPatientAddDesc,
        disposeOnTap: false,
        disableBarrierInteraction: true,
        onTargetClick: _handlePatientsAddTutorialTap,
        child: button,
      );
    }

    return AppShowcase(
      key: _quickRecordKey,
      title: l10n.tutorialHomeRecordTitle,
      description: l10n.tutorialHomeRecordDesc,
      disposeOnTap: false,
      disableBarrierInteraction: true,
      onTargetClick: _handleHomeQuickRecordTutorialTap,
      child: button,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final location = GoRouterState.of(context).matchedLocation;
    final useSideNav = AppLayout.useSideNavigation(context);
    final destinations = _destinations(l10n);

    if (_lastLocation != location) {
      _lastLocation = location;
      // Never setState during build — it corrupts mouse tracking on desktop.
      _scheduleNavLabelReset();
      if (location == AppRoutes.home) {
        _didStartQuickRecordShowcase = false;
      }
      if (location == AppRoutes.patients) {
        _didStartPatientsAddShowcase = false;
      }
      // Leaving a page that registered a primary FAB action — clear it until
      // the new page registers (if any).
      if (_fabPrimaryAction != null) {
        _fabPrimaryAction = null;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _handleTutorialState(context.read<TutorialBloc>().state);
      });
    }

    final tabIndex = indexOfBottomNavDestination(destinations, location);

    final pageBody = BlocListener<TutorialBloc, TutorialState>(
      listener: (context, state) => _handleTutorialState(state),
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: AppTabSlideSwitcher(tabIndex: tabIndex, child: widget.child),
      ),
    );

    final quickRecordFab = _buildQuickRecordFab(l10n);

    final shellBody = useSideNav
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSideNavRail(
                destinations: destinations,
                selectedRoute: location,
                onDestinationSelected: _onDestinationSelected,
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: theme.dividerColor,
              ),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(child: pageBody),
                    Positioned(
                      right: AppSpacing.xl,
                      bottom: AppSpacing.xl,
                      child: quickRecordFab,
                    ),
                  ],
                ),
              ),
            ],
          )
        : Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(child: pageBody),
              Positioned(
                left: 0,
                right: 0,
                bottom: MainShellChrome.navLift,
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
                          child: quickRecordFab,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: AppBreakpoints.contentMaxWidth,
                            ),
                            child: AppBottomNavPill(
                              destinations: destinations,
                              selectedRoute: location,
                              showLabels: _navLabelsVisible,
                              onDestinationSelected: _onDestinationSelected,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );

    return MainShellScope(
      navLabelsVisible: _navLabelsVisible,
      registerFabPrimaryAction: _registerFabPrimaryAction,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        extendBody: !useSideNav,
        resizeToAvoidBottomInset: false,
        body: shellBody,
      ),
    );
  }
}
