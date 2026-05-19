import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/widget/app_text.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    this.title,
    required this.child,
    this.actions,
    this.showDragHandle = true,
  });

  final String? title;
  final Widget child;
  final List<Widget>? actions;
  final bool showDragHandle;

  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    required Widget child,
    List<Widget>? actions,
    bool isDismissible = true,
    bool showDragHandle = true,
    double? heightFraction,
    Widget Function(BuildContext context)? builder,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      showDragHandle: showDragHandle,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
      isScrollControlled: heightFraction != null,
      builder: (context) {
        if (builder != null) {
          return builder(context);
        }

        Widget sheet = AppBottomSheet(
          title: title,
          actions: actions,
          showDragHandle: showDragHandle,
          child: child,
        );

        if (heightFraction != null) {
          final height = MediaQuery.sizeOf(context).height * heightFraction;
          sheet = SizedBox(height: height, child: sheet);
        }

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: sheet,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            AppText(title!, variant: AppTextVariant.title),
            const SizedBox(height: AppSpacing.md),
          ],
          Flexible(child: SingleChildScrollView(child: child)),
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            ...actions!,
          ],
        ],
      ),
    );
  }
}
