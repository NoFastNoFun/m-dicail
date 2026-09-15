import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/recording/domain/session_tags/session_tag_catalog.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/buttons/app_button.dart';
import 'package:medicail/widget/feedback/app_bottom_sheet.dart';
import 'package:medicail/widget/inputs/app_input.dart';

/// Returns selected tag, empty string to clear, or null if dismissed.
class SessionTagPickerSheet extends StatefulWidget {
  const SessionTagPickerSheet({super.key, this.initialTag});

  final String? initialTag;

  static Future<String?> show(
    BuildContext context, {
    String? initialTag,
  }) {
    return AppBottomSheet.present<String?>(
      context,
      builder: (sheetContext) => SessionTagPickerSheet(initialTag: initialTag),
    );
  }

  @override
  State<SessionTagPickerSheet> createState() => _SessionTagPickerSheetState();
}

class _SessionTagPickerSheetState extends State<SessionTagPickerSheet> {
  late String? _selected = SessionTagCatalog.normalize(widget.initialTag);
  late final TextEditingController _customController;
  bool _useCustom = false;

  @override
  void initState() {
    super.initState();
    final initial = _selected;
    final isPreset =
        initial != null && SessionTagCatalog.presets.contains(initial);
    _useCustom = initial != null && !isPreset;
    _customController = TextEditingController(
      text: _useCustom ? initial : '',
    );
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _selectPreset(String preset) {
    setState(() {
      _selected = preset;
      _useCustom = false;
      _customController.clear();
    });
  }

  void _submit() {
    if (_useCustom) {
      Navigator.of(context)
          .pop(SessionTagCatalog.normalize(_customController.text) ?? '');
      return;
    }
    Navigator.of(context).pop(_selected ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AppBottomSheet(
      title: l10n.sessionTagPickerTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final preset in SessionTagCatalog.presets)
                ChoiceChip(
                  label: Text(SessionTagCatalog.label(l10n, preset)),
                  selected: !_useCustom && _selected == preset,
                  onSelected: (_) => _selectPreset(preset),
                ),
              ChoiceChip(
                label: Text(l10n.sessionTagCustomHint),
                selected: _useCustom,
                onSelected: (_) {
                  setState(() {
                    _useCustom = true;
                    _selected = null;
                  });
                },
              ),
            ],
          ),
          if (_useCustom) ...[
            const SizedBox(height: AppSpacing.md),
            AppInput(
              variant: AppInputVariant.text,
              label: l10n.sessionTagCustomHint,
              controller: _customController,
              onChanged: (_) => setState(() {}),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: l10n.buttonSave,
            onPressed: _submit,
          ),
          if (widget.initialTag != null &&
              widget.initialTag!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => Navigator.of(context).pop(''),
              child: AppText(
                l10n.sessionTagClear,
                variant: AppTextVariant.label,
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
