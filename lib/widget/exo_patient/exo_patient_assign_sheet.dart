import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/exo_patient/domain/entities/exercise.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/inputs/app_input.dart';

class ExoPatientAssignResult {
  const ExoPatientAssignResult({
    required this.exercise,
    this.frequency,
    this.notes,
  });

  final Exercise exercise;
  final String? frequency;
  final String? notes;
}

class ExoPatientAssignSheet extends StatefulWidget {
  const ExoPatientAssignSheet({super.key, required this.catalog});

  final List<Exercise> catalog;

  static Future<ExoPatientAssignResult?> show(
    BuildContext context, {
    required List<Exercise> catalog,
  }) {
    return showModalBottomSheet<ExoPatientAssignResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ExoPatientAssignSheet(catalog: catalog),
    );
  }

  @override
  State<ExoPatientAssignSheet> createState() => _ExoPatientAssignSheetState();
}

class _ExoPatientAssignSheetState extends State<ExoPatientAssignSheet> {
  final _frequencyController = TextEditingController();
  final _notesController = TextEditingController();
  Exercise? _selected;

  @override
  void dispose() {
    _frequencyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(l10n.exoPatientPickerTitle, variant: AppTextVariant.title),
          const SizedBox(height: AppSpacing.md),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.catalog.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final exercise = widget.catalog[index];
                final isSelected = exercise.id == _selected?.id;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: AppText(exercise.name, variant: AppTextVariant.body),
                  subtitle: AppText(
                    exercise.description,
                    variant: AppTextVariant.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  onTap: () => setState(() => _selected = exercise),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppInput(
            variant: AppInputVariant.text,
            label: l10n.exoPatientFrequencyLabel,
            controller: _frequencyController,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppInput(
            variant: AppInputVariant.textarea,
            label: l10n.exoPatientNotesLabel,
            controller: _notesController,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: l10n.exoPatientAssignConfirm,
            enabled: _selected != null,
            onPressed: _selected == null
                ? null
                : () => Navigator.of(context).pop(
                      ExoPatientAssignResult(
                        exercise: _selected!,
                        frequency: _frequencyController.text.trim().isEmpty
                            ? null
                            : _frequencyController.text.trim(),
                        notes: _notesController.text.trim().isEmpty
                            ? null
                            : _notesController.text.trim(),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
