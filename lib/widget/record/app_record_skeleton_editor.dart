import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/widget/app_text.dart';

/// Editable SOAP-ish placeholders shown while cloud transcription runs.
/// User notes are kept separately and merged when the AI transcript arrives.
class AppRecordSkeletonEditor extends StatefulWidget {
  const AppRecordSkeletonEditor({
    super.key,
    required this.initialNotes,
    required this.onNotesChanged,
  });

  final String initialNotes;
  final ValueChanged<String> onNotesChanged;

  @override
  State<AppRecordSkeletonEditor> createState() =>
      _AppRecordSkeletonEditorState();
}

class _AppRecordSkeletonEditorState extends State<AppRecordSkeletonEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNotes);
  }

  @override
  void didUpdateWidget(covariant AppRecordSkeletonEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialNotes != oldWidget.initialNotes &&
        widget.initialNotes != _controller.text) {
      _controller.text = widget.initialNotes;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final placeholders = [
      l10n.soapNoteSubjective,
      l10n.soapNoteObjective,
      l10n.soapNoteAssessment,
      l10n.soapNotePlan,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          l10n.recordSkeletonHint,
          variant: AppTextVariant.caption,
          color: context.secondaryTextColor,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final label in placeholders)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: context.secondaryTextColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.smBorder,
                ),
                child: AppText(
                  label,
                  variant: AppTextVariant.caption,
                  color: context.secondaryTextColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: TextField(
            controller: _controller,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            onChanged: widget.onNotesChanged,
            decoration: InputDecoration(
              hintText: l10n.recordSkeletonPlaceholder,
              border: OutlineInputBorder(borderRadius: AppRadius.mdBorder),
              alignLabelWithHint: true,
            ),
          ),
        ),
      ],
    );
  }
}
