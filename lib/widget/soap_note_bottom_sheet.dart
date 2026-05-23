import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';
import 'package:medicail/features/templates/presentation/template_bloc.dart';
import 'package:medicail/features/templates/presentation/template_event.dart';
import 'package:medicail/features/templates/presentation/template_state.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_dialog.dart';
import 'package:medicail/widget/inputs/app_input.dart';
import 'package:medicail/widget/save_template_variant_dialog.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/widget/template_picker_sheet.dart';

class SoapNoteBottomSheet extends StatefulWidget {
  const SoapNoteBottomSheet({
    super.key,
    required this.initialNote,
    required this.onSave,
  });

  final SoapNote initialNote;
  final ValueChanged<SoapNote> onSave;

  static Future<void> show(
    BuildContext context, {
    required SoapNote initialNote,
    required ValueChanged<SoapNote> onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return BlocProvider(
          create: (_) => getIt<TemplateBloc>(),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SoapNoteBottomSheet(
              initialNote: initialNote,
              onSave: onSave,
            ),
          ),
        );
      },
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
  String? _baseTemplateId;
  String? _pendingVariantDisplayName;

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

  SoapNote get _currentNote {
    return SoapNote(
      subjective: _subjectiveController.text,
      objective: _objectiveController.text,
      assessment: _assessmentController.text,
      plan: _planController.text,
    );
  }

  void _applyNote(SoapNote note, {String? baseTemplateId}) {
    setState(() {
      _subjectiveController.text = note.subjective;
      _objectiveController.text = note.objective;
      _assessmentController.text = note.assessment;
      _planController.text = note.plan;
      _baseTemplateId = baseTemplateId;
    });
  }

  void _handleSave() {
    widget.onSave(_currentNote);
    Navigator.of(context).pop();
  }

  void _openTemplatePicker() {
    TemplatePickerSheet.show(
      context,
      onTemplateApplied: (note, {baseTemplateId}) {
        _applyNote(note, baseTemplateId: baseTemplateId);
      },
    );
  }

  void _openSaveVariantDialog() {
    SaveTemplateVariantDialog.show(
      context,
      onSave: (name) {
        _pendingVariantDisplayName = name;
        context.read<TemplateBloc>().add(
              VariantSaveRequested(
                displayName: name,
                soapNote: _currentNote,
                baseTemplateId: _baseTemplateId,
              ),
            );
      },
    );
  }

  void _showDuplicateDialog(TemplateLoaded state) {
    final l10n = AppLocalizations.of(context);
    final existingId = state.pendingDuplicateVariantId;
    if (existingId == null) {
      return;
    }

    AppDialog.show(
      context,
      variant: AppDialogVariant.standard,
      title: l10n.templateDuplicateTitle,
      body: AppText(
        l10n.templateDuplicateMessage,
        variant: AppTextVariant.body,
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.read<TemplateBloc>().add(const TemplateDuplicateDismissed());
            Navigator.of(context).pop();
            _openSaveVariantDialog();
          },
          child: Text(l10n.templateDuplicateRename),
        ),
        TextButton(
          onPressed: () {
            context.read<TemplateBloc>().add(
                  VariantOverwriteConfirmed(
                    existingVariantId: existingId,
                    displayName: _pendingVariantDisplayName ?? '',
                    soapNote: _currentNote,
                    baseTemplateId: _baseTemplateId,
                  ),
                );
            Navigator.of(context).pop();
          },
          child: Text(l10n.templateDuplicateOverwrite),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEmpty = _currentNote.isEmpty;

    return BlocListener<TemplateBloc, TemplateState>(
      listener: (context, state) {
        if (state is TemplateLoaded && state.pendingDuplicateVariantId != null) {
          _showDuplicateDialog(state);
        }
        if (state is TemplateSavingSuccess) {
          AppToast.showSuccess(context, l10n.templateVariantSaveSuccess);
        }
      },
      child: DraggableScrollableSheet(
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
                      AppButton(
                        label: l10n.templateLoadModel,
                        style: AppButtonStyle.secondary,
                        onPressed: _openTemplatePicker,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppInput(
                        variant: AppInputVariant.textarea,
                        label: l10n.soapNoteSubjective,
                        controller: _subjectiveController,
                        maxLines: 4,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppInput(
                        variant: AppInputVariant.textarea,
                        label: l10n.soapNoteObjective,
                        controller: _objectiveController,
                        maxLines: 4,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppInput(
                        variant: AppInputVariant.textarea,
                        label: l10n.soapNoteAssessment,
                        controller: _assessmentController,
                        maxLines: 4,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppInput(
                        variant: AppInputVariant.textarea,
                        label: l10n.soapNotePlan,
                        controller: _planController,
                        maxLines: 4,
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppButton(
                        label: l10n.templateSaveVariant,
                        style: AppButtonStyle.secondary,
                        onPressed: _openSaveVariantDialog,
                        enabled: !isEmpty,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: l10n.soapNoteSave,
                        onPressed: _handleSave,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
