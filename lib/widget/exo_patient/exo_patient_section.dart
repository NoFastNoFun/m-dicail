import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/exo_patient/domain/entities/exercise.dart';
import 'package:medicail/features/exo_patient/domain/entities/patient_exercise.dart';
import 'package:medicail/features/exo_patient/domain/entities/patient_exercise_status.dart';
import 'package:medicail/features/exo_patient/presentation/exo_patient_bloc.dart';
import 'package:medicail/features/exo_patient/presentation/exo_patient_event.dart';
import 'package:medicail/features/exo_patient/presentation/exo_patient_state.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/exo_patient/exo_patient_assign_sheet.dart';

class ExoPatientSection extends StatelessWidget {
  const ExoPatientSection({super.key, required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<ExoPatientBloc>()..add(ExoPatientDataRequested(patientId)),
      child: _ExoPatientSectionContent(patientId: patientId),
    );
  }
}

class _ExoPatientSectionContent extends StatelessWidget {
  const _ExoPatientSectionContent({required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<ExoPatientBloc, ExoPatientState>(
      listener: (context, state) {
        if (state is ExoPatientFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final catalog = switch (state) {
          ExoPatientLoaded(:final catalog) => catalog,
          ExoPatientActionSuccess(:final catalog) => catalog,
          _ => const <Exercise>[],
        };
        final assignments = switch (state) {
          ExoPatientLoaded(:final assignments) => assignments,
          ExoPatientActionSuccess(:final assignments) => assignments,
          _ => const <PatientExercise>[],
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  l10n.exoPatientSectionTitle,
                  variant: AppTextVariant.title,
                ),
                AppButton(
                  label: l10n.exoPatientAssignButton,
                  layout: AppButtonLayout.text,
                  style: AppButtonStyle.secondary,
                  expanded: false,
                  onPressed: catalog.isEmpty
                      ? null
                      : () => _openAssignSheet(context, catalog),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (assignments.isEmpty)
              AppText(l10n.exoPatientEmpty, variant: AppTextVariant.caption)
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    final assignment = assignments[index];
                    return _ExoPatientAssignmentTile(
                      assignment: assignment,
                      exerciseName: _exerciseName(
                        catalog,
                        assignment.exerciseId,
                      ),
                      onStatusChanged: (status) {
                        context.read<ExoPatientBloc>().add(
                              ExoPatientStatusUpdateRequested(
                                patientId: patientId,
                                assignmentId: assignment.id,
                                status: status,
                              ),
                            );
                      },
                      onUnassign: () => context.read<ExoPatientBloc>().add(
                            ExoPatientUnassignRequested(
                              patientId: patientId,
                              assignmentId: assignment.id,
                            ),
                          ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  String _exerciseName(List<Exercise> catalog, String exerciseId) {
    for (final exercise in catalog) {
      if (exercise.id == exerciseId) {
        return exercise.name;
      }
    }
    return exerciseId;
  }

  Future<void> _openAssignSheet(
    BuildContext context,
    List<Exercise> catalog,
  ) async {
    final bloc = context.read<ExoPatientBloc>();
    final result = await ExoPatientAssignSheet.show(context, catalog: catalog);
    if (result == null) {
      return;
    }
    bloc.add(
      ExoPatientAssignRequested(
        patientId: patientId,
        exerciseId: result.exercise.id,
        frequency: result.frequency,
        notes: result.notes,
      ),
    );
  }
}

class _ExoPatientAssignmentTile extends StatelessWidget {
  const _ExoPatientAssignmentTile({
    required this.assignment,
    required this.exerciseName,
    required this.onStatusChanged,
    required this.onUnassign,
  });

  final PatientExercise assignment;
  final String exerciseName;
  final ValueChanged<PatientExerciseStatus> onStatusChanged;
  final VoidCallback onUnassign;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        title: AppText(exerciseName, variant: AppTextVariant.body),
        subtitle: AppText(
          _statusLabel(l10n, assignment.status),
          variant: AppTextVariant.caption,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<PatientExerciseStatus>(
              onSelected: onStatusChanged,
              itemBuilder: (context) => PatientExerciseStatus.values
                  .map(
                    (status) => PopupMenuItem(
                      value: status,
                      child: Text(_statusLabel(l10n, status)),
                    ),
                  )
                  .toList(),
              icon: const Icon(Icons.more_vert),
            ),
            IconButton(
              tooltip: l10n.exoPatientUnassignAction,
              onPressed: () => _confirmUnassign(context),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmUnassign(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.exoPatientUnassignConfirmTitle),
        content: Text(l10n.exoPatientUnassignConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.exoPatientCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.exoPatientUnassignAction),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      onUnassign();
    }
  }

  String _statusLabel(AppLocalizations l10n, PatientExerciseStatus status) {
    return switch (status) {
      PatientExerciseStatus.assigned => l10n.exoPatientStatusAssigned,
      PatientExerciseStatus.inProgress => l10n.exoPatientStatusInProgress,
      PatientExerciseStatus.completed => l10n.exoPatientStatusCompleted,
      PatientExerciseStatus.discontinued => l10n.exoPatientStatusDiscontinued,
    };
  }
}
