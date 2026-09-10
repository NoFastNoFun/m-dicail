import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/error/failure.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/layout/app_breakpoints.dart';
import 'package:medicail/core/layout/main_shell_chrome.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/patient/domain/repositories/patient_repository.dart';
import 'package:medicail/features/patient/presentation/patient_bloc.dart';
import 'package:medicail/features/patient/presentation/patient_event.dart';
import 'package:medicail/features/patient/presentation/patient_state.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_dialog.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/widget/inputs/app_input.dart';

class ArchivedPatientsPage extends StatelessWidget {
  const ArchivedPatientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<PatientBloc>()..add(const PatientsRequested(archived: true)),
      child: const _ArchivedPatientsView(),
    );
  }
}

class _ArchivedPatientsView extends StatefulWidget {
  const _ArchivedPatientsView();

  @override
  State<_ArchivedPatientsView> createState() => _ArchivedPatientsViewState();
}

class _ArchivedPatientsViewState extends State<_ArchivedPatientsView> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  List<Patient> _patients = const [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      context.read<PatientBloc>().add(
        PatientsRequested(
          query: _searchController.text.trim(),
          archived: true,
        ),
      );
    });
  }

  Future<void> _reloadPatients() async {
    final bloc = context.read<PatientBloc>();
    final reloaded = bloc.stream.firstWhere(
      (state) => state is PatientLoaded || state is PatientFailure,
    );
    bloc.add(
      PatientsRequested(
        query: _searchController.text.trim(),
        archived: true,
      ),
    );
    await reloaded;
  }

  Future<void> _openPatientDetail(Patient patient) async {
    await context.pushPatientDetail(patient.id);
    if (!mounted) return;
    await _reloadPatients();
  }

  Future<bool> _deletePatient(Patient patient) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppDialog.show<bool>(
      context,
      variant: AppDialogVariant.standard,
      title: l10n.patientDeleteTitle,
      body: AppText(l10n.patientDeleteBody, variant: AppTextVariant.body),
      actionsBuilder: (dialogContext) => [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: AppText(l10n.buttonCancel, variant: AppTextVariant.label),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: AppText(
            l10n.patientDeleteConfirm,
            variant: AppTextVariant.label,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
    if (confirmed != true || !mounted) return false;
    try {
      await getIt<PatientRepository>().delete(patient.id);
      if (!mounted) return false;
      await _reloadPatients();
      if (!mounted) return false;
      if (context.read<PatientBloc>().state is PatientFailure) return false;
      AppToast.showSuccess(context, l10n.patientDeleteSuccess);
      return true;
    } catch (error) {
      if (mounted) {
        AppToast.showError(context, Failure.fromException(error).message);
      }
      return false;
    }
  }

  Future<void> _restore(Patient patient) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppDialog.show<bool>(
      context,
      variant: AppDialogVariant.standard,
      title: l10n.patientUnarchiveTitle,
      body: AppText(l10n.patientUnarchiveBody, variant: AppTextVariant.body),
      actionsBuilder: (dialogContext) => [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: AppText(l10n.buttonCancel, variant: AppTextVariant.label),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: AppText(
            l10n.patientUnarchiveConfirm,
            variant: AppTextVariant.label,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
    if (confirmed != true || !mounted) return;
    try {
      await getIt<PatientRepository>().unarchive(patient.id);
      if (!mounted) return;
      await _reloadPatients();
      if (!mounted) return;
      AppToast.showSuccess(context, l10n.patientUnarchiveSuccess);
    } catch (error) {
      if (mounted) {
        AppToast.showError(context, Failure.fromException(error).message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<PatientBloc, PatientState>(
      listener: (context, state) {
        if (state is PatientFailure) {
          AppToast.showError(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is PatientLoaded) {
          _patients = state.patients;
        }
        final isLoading = state is PatientLoading;

        return AppScaffold(
          title: l10n.patientsArchivedTitle,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppInput(
                variant: AppInputVariant.text,
                label: l10n.patientSearchPlaceholder,
                controller: _searchController,
                prefixIcon: Icons.search,
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: isLoading && _patients.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _patients.isEmpty
                    ? Center(
                        child: AppText(
                          l10n.patientsArchivedEmpty,
                          variant: AppTextVariant.body,
                          color: context.secondaryTextColor,
                        ),
                      )
                    : _ArchivedPatientList(
                        patients: _patients,
                        padding: MainShellScope.scrollPaddingOf(context),
                        onDelete: _deletePatient,
                        onRestore: _restore,
                        onOpen: _openPatientDetail,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ArchivedPatientList extends StatelessWidget {
  const _ArchivedPatientList({
    required this.patients,
    required this.padding,
    required this.onDelete,
    required this.onRestore,
    required this.onOpen,
  });

  final List<Patient> patients;
  final EdgeInsets padding;
  final Future<bool> Function(Patient patient) onDelete;
  final Future<void> Function(Patient patient) onRestore;
  final Future<void> Function(Patient patient) onOpen;

  @override
  Widget build(BuildContext context) {
    final columns = AppLayout.gridColumnCount(context);

    if (columns <= 1) {
      return ListView.separated(
        padding: padding,
        itemCount: patients.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          return _ArchivedPatientListItem(
            patient: patients[index],
            onDelete: onDelete,
            onRestore: onRestore,
            onOpen: onOpen,
          );
        },
      );
    }

    return GridView.builder(
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        mainAxisExtent: 168,
      ),
      itemCount: patients.length,
      itemBuilder: (context, index) {
        return _ArchivedPatientListItem(
          patient: patients[index],
          onDelete: onDelete,
          onRestore: onRestore,
          onOpen: onOpen,
        );
      },
    );
  }
}

class _ArchivedPatientListItem extends StatelessWidget {
  const _ArchivedPatientListItem({
    required this.patient,
    required this.onDelete,
    required this.onRestore,
    required this.onOpen,
  });

  final Patient patient;
  final Future<bool> Function(Patient patient) onDelete;
  final Future<void> Function(Patient patient) onRestore;
  final Future<void> Function(Patient patient) onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey('patient-delete-${patient.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => onDelete(patient),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: AppRadius.mdBorder,
        ),
        child: Icon(
          Icons.delete_outline,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
      child: InkWell(
        onTap: () => onOpen(patient),
        borderRadius: AppRadius.mdBorder,
        child: Ink(
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
                AppText(
                  patient.displayName,
                  variant: AppTextVariant.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 16,
                      color: context.secondaryTextColor,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: AppText(
                        'MRN: ${patient.mrn}',
                        variant: AppTextVariant.caption,
                        color: context.secondaryTextColor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => onRestore(patient),
                      icon: const Icon(Icons.unarchive_outlined, size: 18),
                      label: AppText(
                        l10n.patientRestoreButton,
                        variant: AppTextVariant.label,
                      ),
                    ),
                    const Spacer(),
                    AppText(
                      l10n.patientOpenButton,
                      variant: AppTextVariant.label,
                      color: context.colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: context.colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
