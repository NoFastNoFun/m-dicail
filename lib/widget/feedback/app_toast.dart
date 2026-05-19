import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_toast_host.dart';

enum AppToastType { success, warning, error, info }

class AppToast {
  AppToast._();

  static void show(
    BuildContext context, {
    required String message,
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    AppToastHost.of(context)?.show(
      overlayContext: context,
      message: message,
      type: type,
      duration: duration,
    );
  }
}

class AppToastWidget extends StatelessWidget {
  const AppToastWidget({
    super.key,
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  final String message;
  final AppToastType type;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
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

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppRadius.mdBorder,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Icon(icon, color: accent, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppText(message, variant: AppTextVariant.body),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: AppColors.textSecondary,
              onPressed: onDismiss,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
