import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_bottom_sheet.dart';
import 'package:medicail/widget/inputs/app_input.dart';

class SoapNoteBottomSheet extends StatefulWidget {
  const SoapNoteBottomSheet({
    super.key,
    required this.initialNote,
    required this.onSave,
    this.transcript,
  });

  final SoapNote initialNote;
  final ValueChanged<SoapNote> onSave;
  final String? transcript;

  static Future<void> show(
    BuildContext context, {
    required SoapNote initialNote,
    required ValueChanged<SoapNote> onSave,
    String? transcript,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.lgBorder,
      ),
      constraints: AppBottomSheet.sheetConstraints(context),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SoapNoteBottomSheet(
          initialNote: initialNote,
          onSave: onSave,
          transcript: transcript,
        ),
      ),
    );
  }

  @override
  State<SoapNoteBottomSheet> createState() => _SoapNoteBottomSheetState();
}

class _SoapNoteBottomSheetState extends State<SoapNoteBottomSheet> {
  late final TextEditingController _subjectiveController;
  late final TextEditingController _objectiveController;
  late final TextEditingController _assessmentController;
  late final TextEditingController _planController;

  @override
  void initState() {
    super.initState();
    _subjectiveController = TextEditingController(text: widget.initialNote.subjective);
    _objectiveController = TextEditingController(text: widget.initialNote.objective);
    _assessmentController = TextEditingController(text: widget.initialNote.assessment);
    _planController = TextEditingController(text: widget.initialNote.plan);
  }

  @override
  void dispose() {
    _subjectiveController.dispose();
    _objectiveController.dispose();
    _assessmentController.dispose();
    _planController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final updatedNote = widget.initialNote.copyWith(
      subjective: _subjectiveController.text,
      objective: _objectiveController.text,
      assessment: _assessmentController.text,
      plan: _planController.text,
    );
    widget.onSave(updatedNote);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: AppText(
                        l10n.soapNoteTitle,
                        variant: AppTextVariant.headline,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    if (widget.transcript != null && widget.transcript!.isNotEmpty) ...[
                      AppText('Transcription brute', variant: AppTextVariant.label),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          borderRadius: AppRadius.mdBorder,
                        ),
                        child: AppText(
                          widget.transcript!,
                          variant: AppTextVariant.body,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    AppInput(
                      variant: AppInputVariant.textarea,
                      label: l10n.soapNoteSubjective,
                      controller: _subjectiveController,
                      maxLines: 4,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppInput(
                      variant: AppInputVariant.textarea,
                      label: l10n.soapNoteObjective,
                      controller: _objectiveController,
                      maxLines: 4,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppInput(
                      variant: AppInputVariant.textarea,
                      label: l10n.soapNoteAssessment,
                      controller: _assessmentController,
                      maxLines: 4,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppInput(
                      variant: AppInputVariant.textarea,
                      label: l10n.soapNotePlan,
                      controller: _planController,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AppButton(
                  label: l10n.soapNoteSave,
                  onPressed: _handleSave,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
