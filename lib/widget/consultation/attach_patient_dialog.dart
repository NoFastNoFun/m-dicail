import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/patient/presentation/patient_bloc.dart';
import 'package:medicail/features/patient/presentation/patient_event.dart';
import 'package:medicail/features/patient/presentation/patient_state.dart';
import 'package:medicail/features/tutorial/domain/tutorial_flow.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_bloc.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_state.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_step_extensions.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_showcase_launcher.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/consultation/new_patient_anamnese_carousel.dart';
import 'package:medicail/widget/feedback/app_showcase.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/widget/inputs/app_input.dart';
import 'package:showcaseview/showcaseview.dart';

/// Fullscreen dialog to attach an existing patient or create a new one
/// (with optional anamnèse) before starting a quick consultation.
class AttachPatientDialog extends StatefulWidget {
  const AttachPatientDialog({super.key});

  /// Returns the selected/created [patientId], or null if cancelled.
  static Future<String?> show(BuildContext context) {
    TutorialBloc? tutorialBloc;
    try {
      tutorialBloc = context.read<TutorialBloc>();
    } catch (_) {}

    return showDialog<String>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (_) {
        Widget child = BlocProvider(
          create: (_) => getIt<PatientBloc>()..add(const PatientsRequested()),
          child: const Dialog.fullscreen(
            child: SafeArea(child: AttachPatientDialog()),
          ),
        );
        if (tutorialBloc != null) {
          child = BlocProvider<TutorialBloc>.value(
            value: tutorialBloc,
            child: child,
          );
        }
        return child;
      },
    );
  }

  @override
  State<AttachPatientDialog> createState() => _AttachPatientDialogState();
}

class _AttachPatientDialogState extends State<AttachPatientDialog> {
  final _searchController = TextEditingController();
  final _attachTutorialKey = GlobalKey();
  bool _showNewPatient = false;
  Patient? _selectedPatient;
  bool _didStartAssignPatientTutorial = false;
  Timer? _assignPatientTutorialTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final tutorialBloc = _tutorialBlocOrNull;
      if (tutorialBloc != null) {
        _handleTutorialState(tutorialBloc.state);
      }
    });
  }

  @override
  void dispose() {
    _assignPatientTutorialTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() => _selectedPatient = null);
    context.read<PatientBloc>().add(
          PatientsRequested(query: _searchController.text.trim()),
        );
  }

  void _handleTutorialState(TutorialState state) {
    if (state is! TutorialInProgress) return;
    if (state.isTutorialStep(TutorialStepId.quickRecordAssignPatient) &&
        !_didStartAssignPatientTutorial) {
      _didStartAssignPatientTutorial = true;
      TutorialShowcaseLauncher.startWhenReady(
        context: context,
        key: _attachTutorialKey,
      ).then((started) {
        if (started && mounted) {
          _scheduleAssignPatientTutorialCompletion();
        }
      });
    }
  }

  TutorialBloc? get _tutorialBlocOrNull {
    try {
      return context.read<TutorialBloc>();
    } catch (_) {
      return null;
    }
  }

  void _scheduleAssignPatientTutorialCompletion() {
    _assignPatientTutorialTimer?.cancel();
    _assignPatientTutorialTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      _completeAssignPatientTutorialStep();
      try {
        ShowcaseView.get().dismiss();
      } catch (_) {}
    });
  }

  void _completeAssignPatientTutorialStep() {
    _assignPatientTutorialTimer?.cancel();
    final tutorialBloc = _tutorialBlocOrNull;
    if (tutorialBloc == null) return;
    if (tutorialBloc.isCurrentStep(TutorialStepId.quickRecordAssignPatient)) {
      tutorialBloc.completeStep(TutorialStepId.quickRecordAssignPatient);
      unawaited(() async {
        await tutorialBloc.skipQuickRecordPageTutorialSteps();
        if (mounted) {
          Navigator.of(context).pop();
        }
      }());
    }
  }

  void _confirmExisting() {
    final tutorialBloc = _tutorialBlocOrNull;
    if (tutorialBloc != null && tutorialBloc.state is TutorialInProgress) {
      _completeAssignPatientTutorialStep();
      return;
    }
    final patient = _selectedPatient;
    if (patient == null) {
      AppToast.showError(
        context,
        AppLocalizations.of(context).attachPatientSelectRequired,
      );
      return;
    }
    Navigator.of(context).pop(patient.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (_showNewPatient) {
      return NewPatientAnamneseCarousel(
        onCancel: () => setState(() => _showNewPatient = false),
      );
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: AppShowcase(
                  key: _attachTutorialKey,
                  title: l10n.tutorialAssignPatientTitle,
                  description: l10n.tutorialAssignPatientDesc,
                  disposeOnTap: true,
                  disableBarrierInteraction: false,
                  onTargetClick: _completeAssignPatientTutorialStep,
                  child: AppText(
                    l10n.attachPatientDialogTitle,
                    variant: AppTextVariant.title,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppInput(
                  variant: AppInputVariant.text,
                  label: l10n.attachPatientSearchLabel,
                  hint: l10n.attachPatientSearchHint,
                  controller: _searchController,
                  prefixIcon: Icons.search,
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: BlocBuilder<PatientBloc, PatientState>(
                    builder: (context, state) {
                      final patients = state is PatientLoaded
                          ? state.patients
                          : <Patient>[];
                      final isLoading = state is PatientLoading;

                      if (isLoading && patients.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (patients.isEmpty) {
                        return Center(
                          child: AppText(
                            l10n.attachPatientNoResults,
                            variant: AppTextVariant.body,
                            color: context.secondaryTextColor,
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: patients.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final patient = patients[index];
                          final selected =
                              _selectedPatient?.id == patient.id;
                          return InkWell(
                            onTap: () => setState(
                              () => _selectedPatient = patient,
                            ),
                            borderRadius: AppRadius.mdBorder,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: selected
                                    ? theme.colorScheme.primaryContainer
                                    : theme.colorScheme.surface,
                                border: Border.all(
                                  color: selected
                                      ? theme.colorScheme.primary
                                      : theme.dividerColor,
                                  width: selected ? 2 : 1,
                                ),
                                borderRadius: AppRadius.mdBorder,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          AppText(
                                            patient.displayName,
                                            variant: AppTextVariant.title,
                                          ),
                                          const SizedBox(
                                            height: AppSpacing.xs,
                                          ),
                                          AppText(
                                            'MRN: ${patient.mrn}',
                                            variant: AppTextVariant.caption,
                                            color: context.secondaryTextColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (selected)
                                      Icon(
                                        Icons.check_circle,
                                        color: theme.colorScheme.primary,
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
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppButton(
                  onPressed:
                      _selectedPatient == null ? null : _confirmExisting,
                  label: l10n.attachPatientConfirm,
                  enabled: _selectedPatient != null,
                  expanded: true,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  onPressed: () => setState(() => _showNewPatient = true),
                  style: AppButtonStyle.secondary,
                  label: l10n.attachPatientNewButton,
                  expanded: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );

    final tutorialBloc = _tutorialBlocOrNull;
    if (tutorialBloc == null) {
      return content;
    }
    return BlocListener<TutorialBloc, TutorialState>(
      listener: (context, state) => _handleTutorialState(state),
      child: content,
    );
  }
}
