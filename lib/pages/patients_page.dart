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
import 'package:medicail/widget/inputs/app_input.dart';

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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<PatientBloc, PatientState>(
      listener: (context, state) {
        if (state is PatientLoaded) {
          _firstNameController.clear();
          _lastNameController.clear();
        }
      },
      builder: (context, state) {
        final patients = state is PatientLoaded ? state.patients : <Patient>[];
        final isLoading = state is PatientLoading;
        final errorMessage = state is PatientFailure ? state.message : null;

        return AppScaffold(
          title: l10n.patientsTitle,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppInput(
                variant: AppInputVariant.text,
                label: l10n.patientFirstNameLabel,
                controller: _firstNameController,
              ),
              const SizedBox(height: AppSpacing.md),
              AppInput(
                variant: AppInputVariant.text,
                label: l10n.patientLastNameLabel,
                controller: _lastNameController,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.patientCreateButton,
                isLoading: isLoading,
                onPressed: _createPatient,
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                AppText(
                  errorMessage,
                  variant: AppTextVariant.body,
                  color: AppColors.error,
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppText(l10n.patientsSectionTitle, variant: AppTextVariant.title),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: patients.isEmpty
                    ? Center(
                        child: AppText(
                          l10n.patientsEmpty,
                          variant: AppTextVariant.body,
                          color: AppColors.textSecondary,
                        ),
                      )
                    : ListView.separated(
                        itemCount: patients.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          return _PatientListItem(patient: patients[index]);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _createPatient() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    if (firstName.isEmpty || lastName.isEmpty) {
      return;
    }
    context.read<PatientBloc>().add(
          PatientCreated(firstName: firstName, lastName: lastName),
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
            AppText(
              patient.id,
              variant: AppTextVariant.caption,
              color: AppColors.textSecondary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
