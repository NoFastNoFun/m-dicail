import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/widget/app_text.dart';

enum AppDialogVariant { standard, fullscreen, lockScreen }

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.variant = AppDialogVariant.standard,
  });

  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final AppDialogVariant variant;

  static Future<T?> show<T>(
    BuildContext context, {
    required AppDialogVariant variant,
    String? title,
    required Widget body,
    List<Widget> Function(BuildContext dialogContext)? actionsBuilder,
  }) {
    final barrierDismissible = variant != AppDialogVariant.lockScreen;

    if (variant == AppDialogVariant.fullscreen) {
      return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (dialogContext) => AppDialog(
          variant: variant,
          title: title,
          body: body,
          actions: actionsBuilder?.call(dialogContext),
        ),
      );
    }

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) => PopScope(
        canPop: variant != AppDialogVariant.lockScreen,
        child: AppDialog(
          variant: variant,
          title: title,
          body: body,
          actions: actionsBuilder?.call(dialogContext),
        ),
      ),
    );
  }

  bool get _usesHighContrast =>
      variant == AppDialogVariant.lockScreen ||
      variant == AppDialogVariant.fullscreen;

  Color get _backgroundColor =>
      _usesHighContrast ? AppColors.highContrastWhite : AppColors.background;

  Widget _wrapContent(BuildContext context, Widget content) {
    if (!_usesHighContrast) {
      return content;
    }

    return Theme(
      data: Theme.of(context).highContrastSurface,
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _wrapContent(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            AppText(title!, variant: AppTextVariant.title),
            const SizedBox(height: AppSpacing.md),
          ],
          body,
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: actions!,
            ),
          ],
        ],
      ),
    );

    if (variant == AppDialogVariant.fullscreen) {
      return Dialog.fullscreen(
        backgroundColor: _backgroundColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: content,
          ),
        ),
      );
    }

    return AlertDialog(
      backgroundColor: _backgroundColor,
      shape: variant == AppDialogVariant.lockScreen
          ? AppRadius.onboardingMdShape
          : null,
      contentPadding: const EdgeInsets.all(AppSpacing.lg),
      content: content,
    );
  }
}
