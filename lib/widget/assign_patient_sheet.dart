import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/patient/presentation/patient_bloc.dart';
import 'package:medicail/features/patient/presentation/patient_event.dart';
import 'package:medicail/features/patient/presentation/patient_state.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:medicail/features/tutorial/domain/tutorial_flow.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_bloc.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_state.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_step_extensions.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/widget/inputs/app_input.dart';
import 'package:medicail/widget/patient_creation_sheet.dart';
import 'package:showcaseview/showcaseview.dart';

class AssignPatientSheet extends StatefulWidget {
  const AssignPatientSheet({
    super.key,
    required this.sessionId,
    required this.onAssigned,
  });

  final String sessionId;
  final ValueChanged<String> onAssigned;

  static void show(BuildContext context, String sessionId) {
    final router = GoRouter.of(context);

    void openAssignedPatient(String patientId) {
      if (context.mounted && context.canPop()) {
        context.pop();
      }
      router.push('/patients/$patientId');
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider(
          create: (_) => getIt<PatientBloc>()..add(const PatientsRequested()),
          child: AssignPatientSheet(
            sessionId: sessionId,
            onAssigned: openAssignedPatient,
          ),
        );
      },
    );
  }

  @override
  State<AssignPatientSheet> createState() => _AssignPatientSheetState();

  static Future<void> _assignAndNavigate(
    BuildContext context,
    String sessionId,
    String patientId,
    ValueChanged<String> onAssigned,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repo = getIt<RecordingSessionRepository>();
      await repo.associatePatient(sessionId, patientId);
      if (context.mounted) {
        await Navigator.of(context).maybePop();
        onAssigned(patientId);
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.showError(context, l10n.assignPatientError);
      }
    }
  }
}

class _AssignPatientSheetState extends State<AssignPatientSheet> {
  final GlobalKey _assignPatientTutorialKey = GlobalKey();
  Timer? _assignPatientTutorialTimer;
  bool _didStartAssignPatientTutorial = false;

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
    if (!state.isTutorialStep(TutorialStepId.quickRecordAssignPatient)) return;
    if (_didStartAssignPatientTutorial) return;
    _didStartAssignPatientTutorial = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ShowcaseView.get().startShowCase(
        [_assignPatientTutorialKey],
        delay: const Duration(milliseconds: 250),
      );
      _scheduleAssignPatientTutorialCompletion();
    });
  }

  void _scheduleAssignPatientTutorialCompletion() {
    _assignPatientTutorialTimer?.cancel();
    _assignPatientTutorialTimer = Timer(const Duration(seconds: 7), () {
      if (!mounted) return;
      final tutorialBloc = context.read<TutorialBloc>();
      if (!tutorialBloc.isCurrentStep(
        TutorialStepId.quickRecordAssignPatient,
      )) {
        return;
      }
      ShowcaseView.get().dismiss();
      tutorialBloc.completeStep(TutorialStepId.quickRecordAssignPatient);
    });
  }

  void _completeAssignPatientTutorialStep() {
    _assignPatientTutorialTimer?.cancel();
    context.read<TutorialBloc>().completeStep(
      TutorialStepId.quickRecordAssignPatient,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<TutorialBloc, TutorialState>(
      listener: (context, state) => _handleTutorialState(state),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
              Showcase(
                key: _assignPatientTutorialKey,
                title: l10n.tutorialAssignPatientTitle,
                description: l10n.tutorialAssignPatientDesc,
                disposeOnTap: true,
                onTargetClick: _completeAssignPatientTutorialStep,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: AppText(
                        l10n.assignPatientTitle,
                        variant: AppTextVariant.title,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TabBar(
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.primary,
                      tabs: [
                        Tab(text: l10n.assignPatientSearchTab),
                        Tab(text: l10n.assignPatientNewTab),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _PatientSearchTab(
                      sessionId: widget.sessionId,
                      onAssigned: widget.onAssigned,
                    ),
                    PatientCreationSheet(
                      onSuccess: (patientId) =>
                          AssignPatientSheet._assignAndNavigate(
                            context,
                            widget.sessionId,
                            patientId,
                            widget.onAssigned,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientSearchTab extends StatefulWidget {
  const _PatientSearchTab({required this.sessionId, required this.onAssigned});

  final String sessionId;
  final ValueChanged<String> onAssigned;

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
    context.read<PatientBloc>().add(
      PatientsRequested(query: _searchController.text.trim()),
    );
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
                final patients = state is PatientLoaded
                    ? state.patients
                    : <Patient>[];
                final isLoading = state is PatientLoading;

                if (isLoading && patients.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (patients.isEmpty) {
                  return Center(
                    child: AppText(
                      l10n.patientsEmpty,
                      variant: AppTextVariant.body,
                      color: AppColors.textSecondary,
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: patients.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    return InkWell(
                      onTap: () => AssignPatientSheet._assignAndNavigate(
                        context,
                        widget.sessionId,
                        patient.id,
                        widget.onAssigned,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.border),
                          borderRadius: AppRadius.mdBorder,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppText(
                                patient.displayName,
                                variant: AppTextVariant.title,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              AppText(
                                'MRN: ${patient.mrn}',
                                variant: AppTextVariant.caption,
                                color: AppColors.textSecondary,
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
