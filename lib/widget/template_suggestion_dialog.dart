import 'package:flutter/material.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/templates/domain/entities/template_suggestion.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_dialog.dart';

enum TemplateSuggestionAction { apply, chooseOther, skip }

class TemplateSuggestionDialog extends StatelessWidget {
  const TemplateSuggestionDialog({
    super.key,
    required this.suggestion,
  });

  final TemplateSuggestion suggestion;

  static Future<TemplateSuggestionAction?> show(
    BuildContext context, {
    required TemplateSuggestion suggestion,
  }) {
    return AppDialog.show<TemplateSuggestionAction>(
      context,
      variant: AppDialogVariant.standard,
      title: AppLocalizations.of(context).templateSuggestionTitle,
      body: TemplateSuggestionDialog(suggestion: suggestion),
      actions: const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          l10n.templateSuggestionMessage(suggestion.template.pathologyName),
          variant: AppTextVariant.body,
        ),
        const SizedBox(height: 16),
        AppButton(
          label: l10n.templateSuggestionApply,
          onPressed: () => Navigator.of(context).pop(TemplateSuggestionAction.apply),
        ),
        const SizedBox(height: 8),
        AppButton(
          label: l10n.templateSuggestionChooseOther,
          style: AppButtonStyle.secondary,
          onPressed: () =>
              Navigator.of(context).pop(TemplateSuggestionAction.chooseOther),
        ),
        const SizedBox(height: 8),
        AppButton(
          label: l10n.templateSuggestionSkip,
          style: AppButtonStyle.secondary,
          onPressed: () => Navigator.of(context).pop(TemplateSuggestionAction.skip),
        ),
      ],
    );
  }
}
