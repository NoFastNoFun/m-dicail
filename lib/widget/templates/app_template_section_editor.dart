import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/features/note_template/domain/entities/note_section.dart';
import 'package:medicail/features/note_template/domain/entities/note_section_kind.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/inputs/app_input.dart';

class AppTemplateSectionEditor extends StatefulWidget {
  const AppTemplateSectionEditor({
    super.key,
    required this.section,
    required this.titleLabel,
    required this.promptLabel,
    required this.onTitleChanged,
    required this.onPromptChanged,
    this.onDelete,
    this.canDelete = false,
  });

  final NoteSection section;
  final String titleLabel;
  final String promptLabel;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onPromptChanged;
  final VoidCallback? onDelete;
  final bool canDelete;

  @override
  State<AppTemplateSectionEditor> createState() =>
      _AppTemplateSectionEditorState();
}

class _AppTemplateSectionEditorState extends State<AppTemplateSectionEditor> {
  late final TextEditingController _titleController;
  late final TextEditingController _promptController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.section.title);
    _promptController = TextEditingController(text: widget.section.prompt);
  }

  @override
  void didUpdateWidget(covariant AppTemplateSectionEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.section.id != widget.section.id) {
      _titleController.text = widget.section.title;
      _promptController.text = widget.section.prompt;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = widget.section.kind == NoteSectionKind.custom;
    final displayTitle =
        isCustom ? widget.section.title : _soapSectionLabel(widget.section.kind);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppText(
                    displayTitle,
                    variant: AppTextVariant.title,
                  ),
                ),
                if (widget.canDelete && widget.onDelete != null)
                  IconButton(
                    onPressed: widget.onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            if (isCustom) ...[
              const SizedBox(height: AppSpacing.sm),
              AppInput(
                variant: AppInputVariant.text,
                label: widget.titleLabel,
                controller: _titleController,
                onChanged: widget.onTitleChanged,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            AppInput(
              variant: AppInputVariant.textarea,
              label: widget.promptLabel,
              controller: _promptController,
              onChanged: widget.onPromptChanged,
              maxLines: 6,
            ),
          ],
        ),
      ),
    );
  }

  String _soapSectionLabel(NoteSectionKind kind) {
    return switch (kind) {
      NoteSectionKind.subjective => 'Subjectif (S)',
      NoteSectionKind.objective => 'Objectif (O)',
      NoteSectionKind.assessment => 'Evaluation (A)',
      NoteSectionKind.plan => 'Plan (P)',
      NoteSectionKind.custom => 'Section',
    };
  }
}
