import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_bottom_sheet.dart';
import 'package:medicail/widget/inputs/app_input.dart';
import 'package:medicail/widget/legal/app_eu_ai_label.dart';

class SoapNoteBottomSheet extends StatefulWidget {
  const SoapNoteBottomSheet({
    super.key,
    required this.initialNote,
    required this.onSave,
    this.transcript,
    this.showTranscript = true,
  });

  final SoapNote initialNote;
  final ValueChanged<SoapNote> onSave;
  final String? transcript;
  final bool showTranscript;

  static Future<void> show(
    BuildContext context, {
    required SoapNote initialNote,
    required ValueChanged<SoapNote> onSave,
    String? transcript,
    bool showTranscript = true,
  }) {
    return AppBottomSheet.present(
      context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      constraints: AppBottomSheet.sheetConstraints(context),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SoapNoteBottomSheet(
          initialNote: initialNote,
          onSave: onSave,
          transcript: transcript,
          showTranscript: showTranscript,
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
    final asDialog = AppBottomSheet.usesDialog(context);

    Widget body(ScrollController? scrollController) {
      return SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: AppText(
                            l10n.soapNoteTitle,
                            variant: AppTextVariant.headline,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const AppEuAiLabel(kind: EuAiLabelKind.generated),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: context.secondaryTextColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  if (widget.showTranscript &&
                      widget.transcript != null &&
                      widget.transcript!.isNotEmpty) ...[
                    AppText('Transcription brute', variant: AppTextVariant.label),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: AppRadius.mdBorder,
                      ),
                      child: AppText(
                        widget.transcript!,
                        variant: AppTextVariant.body,
                        color: context.secondaryTextColor,
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
    }

    if (asDialog) {
      return SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.85,
        child: body(null),
      );
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => body(scrollController),
    );
  }
}
