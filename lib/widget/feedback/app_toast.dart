import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/error/last_api_error_report.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_toast_host.dart';

enum AppToastType { success, warning, error, info }

class AppToast {
  AppToast._();

  static const String errorReportFormUrl =
      'https://forms.gle/q37qQwNVhezKx1mLA';

  static void show(
    BuildContext context, {
    required String message,
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 3),
    String? details,
  }) {
    AppToastHost.of(context)?.show(
      overlayContext: context,
      message: message,
      type: type,
      duration: duration,
      details: details,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 6),
    String? details,
  }) {
    show(
      context,
      message: message,
      type: AppToastType.error,
      duration: duration,
      details: details ?? LastApiErrorReport.details,
    );
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(context, message: message, type: AppToastType.success, duration: duration);
  }
}

class AppToastWidget extends StatelessWidget {
  const AppToastWidget({
    super.key,
    required this.message,
    required this.type,
    required this.onDismiss,
    this.details,
    this.onCopyDetails,
    this.onReport,
  });

  final String message;
  final AppToastType type;
  final VoidCallback onDismiss;
  final String? details;
  final VoidCallback? onCopyDetails;
  final VoidCallback? onReport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final accent = switch (type) {
      AppToastType.success => AppColors.success,
      AppToastType.warning => AppColors.warning,
      AppToastType.error => AppColors.error,
      AppToastType.info => AppColors.info,
    };

    final icon = switch (type) {
      AppToastType.success => Icons.check_circle_outline,
      AppToastType.warning => Icons.warning_amber_outlined,
      AppToastType.error => Icons.error_outline,
      AppToastType.info => Icons.info_outline,
    };

    final messageArea = Row(
      children: [
        Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Icon(icon, color: accent, size: 22),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: AppText(message, variant: AppTextVariant.body),
        ),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: AppRadius.mdBorder,
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: onCopyDetails == null
                  ? messageArea
                  : InkWell(
                      onTap: onCopyDetails,
                      borderRadius: AppRadius.mdBorder,
                      child: messageArea,
                    ),
            ),
            if (onReport != null)
              IconButton(
                icon: const Icon(Icons.bug_report_outlined, size: 20),
                color: context.secondaryTextColor,
                tooltip: l10n.errorToastReport,
                onPressed: onReport,
                visualDensity: VisualDensity.compact,
              ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: context.secondaryTextColor,
              onPressed: onDismiss,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
