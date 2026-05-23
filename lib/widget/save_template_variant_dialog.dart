import 'package:flutter/material.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/feedback/app_dialog.dart';
import 'package:medicail/widget/inputs/app_input.dart';

class SaveTemplateVariantDialog extends StatefulWidget {
  const SaveTemplateVariantDialog({
    super.key,
    required this.onSave,
    this.initialName = '',
  });

  final ValueChanged<String> onSave;
  final String initialName;

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<String> onSave,
    String initialName = '',
  }) {
    return AppDialog.show(
      context,
      variant: AppDialogVariant.standard,
      title: AppLocalizations.of(context).templateSaveVariant,
      body: SaveTemplateVariantDialog(
        onSave: onSave,
        initialName: initialName,
      ),
      actions: const [],
    );
  }

  @override
  State<SaveTemplateVariantDialog> createState() =>
      _SaveTemplateVariantDialogState();
}

class _SaveTemplateVariantDialogState extends State<SaveTemplateVariantDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }
    widget.onSave(name);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canSave = _nameController.text.trim().isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInput(
          variant: AppInputVariant.text,
          label: l10n.templateVariantNameLabel,
          hint: l10n.templateVariantNameHint,
          controller: _nameController,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        AppButton(
          label: l10n.templateVariantSaveAction,
          onPressed: _submit,
          enabled: canSave,
        ),
        const SizedBox(height: 8),
        AppButton(
          label: l10n.templateVariantCancelAction,
          style: AppButtonStyle.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
