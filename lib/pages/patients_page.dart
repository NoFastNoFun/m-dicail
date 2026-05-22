import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/patient/presentation/patient_bloc.dart';
import 'package:medicail/features/patient/presentation/patient_event.dart';
import 'package:medicail/features/patient/presentation/patient_state.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/widget/inputs/app_input.dart';
import 'package:medicail/widget/patient_creation_sheet.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_bloc.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_event.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_state.dart';
import 'package:showcaseview/showcaseview.dart';

class PatientsPage extends StatelessWidget {
  const PatientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PatientBloc>()..add(const PatientsRequested()),
      child: const _PatientsView(),
    );
  }
}

class _PatientsView extends StatefulWidget {
  const _PatientsView();

  @override
  State<_PatientsView> createState() => _PatientsViewState();
}

class _PatientsViewState extends State<_PatientsView> {
  final _searchController = TextEditingController();
  final GlobalKey _addPatientKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    ShowcaseView.register();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    ShowcaseView.get().unregister();
    super.dispose();
  }

  void _onSearchChanged() {
    context
        .read<PatientBloc>()
        .add(PatientsRequested(query: _searchController.text.trim()));
  }

  void _showCreatePatientSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: BlocProvider.value(
            value: context.read<PatientBloc>(),
            child: const PatientCreationSheet(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<PatientBloc, PatientState>(
      listener: (context, state) {
        if (state is PatientFailure) {
          AppToast.showError(context, state.message);
        }
        if (state is PatientMrnConflict) {
          AppToast.showError(context, l10n.patientMrnConflict);
        }
      },
      builder: (context, state) {
        final patients = state is PatientLoaded ? state.patients : <Patient>[];
        final isLoading = state is PatientLoading;

        return AppScaffold(
          title: l10n.patientsTitle,
          actions: [
            Showcase(
              key: _addPatientKey,
              title: l10n.tutorialPatientAddTitle,
              description: l10n.tutorialPatientAddDesc,
              disposeOnTap: true,
              onTargetClick: () {
                context.read<TutorialBloc>().add(const TutorialStepCompleted(2));
                _showCreatePatientSheet(context);
              },
              child: IconButton(
                icon: const Icon(Icons.add, color: AppColors.textPrimary),
                onPressed: () {
                  if (context.read<TutorialBloc>().state is TutorialInProgress) {
                    context.read<TutorialBloc>().add(const TutorialStepCompleted(2));
                  }
                  _showCreatePatientSheet(context);
                },
              ),
            ),
          ],
          body: BlocListener<TutorialBloc, TutorialState>(
            listener: (context, state) {
              if (state is TutorialInProgress && state.currentStep == 2) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ShowcaseView.get().startShowCase([_addPatientKey]);
                });
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppInput(
                variant: AppInputVariant.text,
                label: l10n.patientSearchPlaceholder,
                controller: _searchController,
                prefixIcon: Icons.search,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppText(l10n.patientsSectionTitle, variant: AppTextVariant.title),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: isLoading && patients.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : patients.isEmpty
                        ? Center(
                            child: AppText(
                              l10n.patientsEmpty,
                              variant: AppTextVariant.body,
                              color: AppColors.textSecondary,
                            ),
                          )
                        : ListView.separated(
                            itemCount: patients.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) {
                              return _PatientListItem(patient: patients[index]);
                            },
                          ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }
}

class _PatientListItem extends StatelessWidget {
  const _PatientListItem({required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
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
            AppText(patient.displayName, variant: AppTextVariant.title),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.badge_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: AppText(
                    'MRN: ${patient.mrn}',
                    variant: AppTextVariant.caption,
                    color: AppColors.textSecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.patientOpenButton,
              style: AppButtonStyle.secondary,
              onPressed: () => context.goPatientDetail(patient.id),
            ),
          ],
        ),
      ),
    );
  }
}

