import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/pathology/domain/entities/pathology.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_bottom_sheet.dart';
import 'package:medicail/widget/templates/pathology_picker_sheet.dart';

class PathologyAttachPromptSheet extends StatelessWidget {
  const PathologyAttachPromptSheet({
    super.key,
    required this.pathologies,
  });

  final List<Pathology> pathologies;

  static Future<Pathology?> show(
    BuildContext context, {
    required List<Pathology> pathologies,
  }) {
    return showModalBottomSheet<Pathology>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.lgBorder,
      ),
      constraints: AppBottomSheet.sheetConstraints(context),
      builder: (context) => PathologyAttachPromptSheet(
        pathologies: pathologies,
      ),
    );
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
          AppText(
            l10n.pathologyNoneSuggestionTitle,
            variant: AppTextVariant.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            l10n.pathologyNoneSuggestionDesc,
            variant: AppTextVariant.body,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: l10n.pathologyNoneSuggestionAttach,
            onPressed: () async {
              final pathology = await PathologyPickerSheet.show(
                context,
                pathologies: pathologies,
              );
              if (!context.mounted) {
                return;
              }
              Navigator.of(context).pop(pathology);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l10n.pathologySuggestionSkip,
            style: AppButtonStyle.tertiary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
