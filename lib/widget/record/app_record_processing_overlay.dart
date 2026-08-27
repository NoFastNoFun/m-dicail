import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/widget/app_text.dart';

class AppRecordProcessingOverlay extends StatelessWidget {
  const AppRecordProcessingOverlay({
    super.key,
    required this.isTranscribingBackground,
    required this.isEnhancing,
  });

  final bool isTranscribingBackground;
  final bool isEnhancing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final String message = isTranscribingBackground
        ? l10n.recordStatusTranscribingBackground
        : isEnhancing
            ? l10n.recordStatusEnhancing
            : l10n.recordStatusGeneratingSOAP;

    return Container(
      color: AppColors.highContrastBlack.withValues(alpha: 0.54),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppColors.highContrastWhite,
            ),
            const SizedBox(height: AppSpacing.md),
            AppText(
              message,
              variant: AppTextVariant.body,
              color: AppColors.highContrastWhite,
            ),
          ],
        ),
      ),
    );
  }
}
