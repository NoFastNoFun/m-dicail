import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/buttons/app_button.dart';

class AppAiTranscribingCard extends StatelessWidget {
  const AppAiTranscribingCard({
    super.key,
    required this.etaLabel,
    required this.onContinueInBackground,
  });

  final String etaLabel;
  final VoidCallback onContinueInBackground;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 2,
      borderRadius: AppRadius.mdBorder,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: AppRadius.mdBorder,
          border: Border.all(color: theme.dividerColor),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.info.withValues(alpha: 0.08),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        l10n.recordAiTranscribingTitle,
                        variant: AppTextVariant.label,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      AppText(
                        etaLabel,
                        variant: AppTextVariant.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.recordAiTranscribingContinueBackground,
              style: AppButtonStyle.secondary,
              onPressed: onContinueInBackground,
            ),
          ],
        ),
      ),
    );
  }
}
