import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
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

  @override
  Widget build(BuildContext context) {
    final content = Column(
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
    );

    if (variant == AppDialogVariant.fullscreen) {
      return Dialog.fullscreen(
        backgroundColor: AppColors.background,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: content,
          ),
        ),
      );
    }

    return AlertDialog(
      backgroundColor: AppColors.background,
      contentPadding: const EdgeInsets.all(AppSpacing.lg),
      content: content,
    );
  }
}
