import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/patient/presentation/patient_bloc.dart';
import 'package:medicail/features/patient/presentation/patient_event.dart';
import 'package:medicail/features/patient/presentation/patient_state.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'dart:async';
import 'package:medicail/widget/inputs/app_input.dart';
import 'package:medicail/widget/patient_creation_sheet.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:medicail/features/tutorial/domain/tutorial_flow.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_bloc.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_state.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_step_extensions.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_showcase_launcher.dart';

class AssignPatientSheet extends StatefulWidget {
  const AssignPatientSheet({super.key, required this.sessionId});

  final String sessionId;

  static void show(BuildContext context, String sessionId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider(
          create: (_) => getIt<PatientBloc>()..add(const PatientsRequested()),
          child: AssignPatientSheet(sessionId: sessionId),
        );
      },
    );
  }

  @override
  State<AssignPatientSheet> createState() => _AssignPatientSheetState();
}

class _AssignPatientSheetState extends State<AssignPatientSheet> {
  final _assignPatientTutorialKey = GlobalKey();
  bool _didStartAssignPatientTutorial = false;
  Timer? _assignPatientTutorialTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _handleTutorialState(context.read<TutorialBloc>().state);
    });
  }

  @override
  void dispose() {
    _assignPatientTutorialTimer?.cancel();
    super.dispose();
  }

  void _handleTutorialState(TutorialState state) {
    if (state is! TutorialInProgress) return;
    if (state.isTutorialStep(TutorialStepId.quickRecordAssignPatient) &&
        !_didStartAssignPatientTutorial) {
      _didStartAssignPatientTutorial = true;
      TutorialShowcaseLauncher.startWhenReady(
        context: context,
        key: _assignPatientTutorialKey,
      ).then((started) {
        if (started && mounted) {
          _scheduleAssignPatientTutorialCompletion();
        }
      });
    }
  }

  void _scheduleAssignPatientTutorialCompletion() {
    _assignPatientTutorialTimer?.cancel();
    _assignPatientTutorialTimer = Timer(const Duration(seconds: 7), () {
      if (!mounted) return;
      _completeAssignPatientTutorialStep();
      ShowcaseView.get().dismiss();
    });
  }

  void _completeAssignPatientTutorialStep() {
    _assignPatientTutorialTimer?.cancel();
    final tutorialBloc = context.read<TutorialBloc>();
    if (tutorialBloc.isCurrentStep(TutorialStepId.quickRecordAssignPatient)) {
      tutorialBloc.completeStep(TutorialStepId.quickRecordAssignPatient);
    }
  }

  Future<void> _assignAndNavigate(BuildContext context, String patientId) async {
    _completeAssignPatientTutorialStep();
    final l10n = AppLocalizations.of(context);
    try {
      final repo = getIt<RecordingSessionRepository>();
      final session = await repo.getById(widget.sessionId);
      if (session != null) {
        await repo.save(session.copyWith(patientId: patientId));
      }
      if (context.mounted) {
        Navigator.of(context).pop(); // Fermer la modale
        if (context.canPop()) {
          context.pop(); // Fermer la page de record si besoin
        }
        context.goPatientDetail(patientId);
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.showError(context, l10n.assignPatientError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: AppSpacing.lg,
      ),
      height: MediaQuery.of(context).size.height * 0.85,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: BlocListener<TutorialBloc, TutorialState>(
                listener: (context, state) => _handleTutorialState(state),
                child: Showcase(
                  key: _assignPatientTutorialKey,
                  title: l10n.tutorialAssignPatientTitle,
                  description: l10n.tutorialAssignPatientDesc,
                  disposeOnTap: false,
                  disableBarrierInteraction: true,
                  onTargetClick: _completeAssignPatientTutorialStep,
                  child: AppText(
                    l10n.assignPatientTitle,
                    variant: AppTextVariant.title,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TabBar(
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: context.secondaryTextColor,
              indicatorColor: theme.colorScheme.primary,
              tabs: [
                Tab(text: l10n.assignPatientSearchTab),
                Tab(text: l10n.assignPatientNewTab),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _PatientSearchTab(
                    sessionId: widget.sessionId,
                    onAssign: (patientId) => _assignAndNavigate(context, patientId),
                  ),
                  PatientCreationSheet(
                    onSuccess: (patientId) => _assignAndNavigate(context, patientId),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientSearchTab extends StatefulWidget {
  const _PatientSearchTab({required this.sessionId, required this.onAssign});

  final String sessionId;
  final ValueChanged<String> onAssign;

  @override
  State<_PatientSearchTab> createState() => _PatientSearchTabState();
}

class _PatientSearchTabState extends State<_PatientSearchTab> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context
        .read<PatientBloc>()
        .add(PatientsRequested(query: _searchController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppInput(
            variant: AppInputVariant.text,
            label: l10n.patientSearchPlaceholder,
            controller: _searchController,
            prefixIcon: Icons.search,
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: BlocBuilder<PatientBloc, PatientState>(
              builder: (context, state) {
                final patients = state is PatientLoaded ? state.patients : <Patient>[];
                final isLoading = state is PatientLoading;

                if (isLoading && patients.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (patients.isEmpty) {
                  return Center(
                    child: AppText(
                      l10n.patientsEmpty,
                      variant: AppTextVariant.body,
                      color: context.secondaryTextColor,
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: patients.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    final theme = Theme.of(context);
                    return InkWell(
                      onTap: () => widget.onAssign(patient.id),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: AppRadius.mdBorder,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppText(patient.displayName, variant: AppTextVariant.title),
                              const SizedBox(height: AppSpacing.xs),
                              AppText(
                                'MRN: ${patient.mrn}',
                                variant: AppTextVariant.caption,
                                color: context.secondaryTextColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
