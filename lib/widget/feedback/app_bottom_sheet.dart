import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/layout/app_breakpoints.dart';
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

  /// Expanded / desktop-wide layouts present as a centered dialog instead of
  /// a modal bottom sheet. Compact / mobile keep the sheet.
  static bool usesDialog(BuildContext context) => AppLayout.isExpanded(context);

  static BoxConstraints sheetConstraints(BuildContext context) {
    return BoxConstraints(
      maxWidth: AppBreakpoints.sheetMaxWidth,
      maxHeight: MediaQuery.sizeOf(context).height * 0.92,
    );
  }

  static BoxConstraints dialogConstraints(BuildContext context) {
    return BoxConstraints(
      maxWidth: AppBreakpoints.sheetMaxWidth,
      maxHeight: MediaQuery.sizeOf(context).height * 0.92,
    );
  }

  static ShapeBorder get _dialogShape => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      );

  static ShapeBorder get _sheetShape => const RoundedRectangleBorder(
        borderRadius: AppRadius.lgBorder,
      );

  /// Adaptive entry point for form sheets: compact → modal bottom sheet,
  /// expanded → centered [Dialog] capped at [AppBreakpoints.sheetMaxWidth].
  ///
  /// Call sites can keep passing the same [builder] content; drag-handle and
  /// sheet-only chrome apply only on the sheet path.
  static Future<T?> present<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showDragHandle = false,
    bool isScrollControlled = true,
    bool useRootNavigator = false,
    bool useSafeArea = false,
    Color? backgroundColor,
    ShapeBorder? shape,
    BoxConstraints? constraints,
  }) {
    final resolvedConstraints = constraints ?? sheetConstraints(context);

    if (usesDialog(context)) {
      final theme = Theme.of(context);
      // Transparent sheet backgrounds paint their own surface; for dialogs use
      // the theme surface so the rounded clip reads as a proper card.
      final dialogBackground = backgroundColor == null ||
              backgroundColor == Colors.transparent
          ? theme.colorScheme.surface
          : backgroundColor;

      return showDialog<T>(
        context: context,
        barrierDismissible: isDismissible,
        useRootNavigator: useRootNavigator,
        builder: (dialogContext) {
          Widget child = builder(dialogContext);
          if (useSafeArea) {
            child = SafeArea(child: child);
          }
          return Dialog(
            backgroundColor: dialogBackground,
            elevation: 6,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xl,
            ),
            shape: _dialogShape,
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: dialogConstraints(dialogContext).copyWith(
                maxWidth: resolvedConstraints.maxWidth,
              ),
              child: child,
            ),
          );
        },
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag && isDismissible,
      showDragHandle: showDragHandle,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      useSafeArea: useSafeArea,
      backgroundColor:
          backgroundColor ?? Theme.of(context).colorScheme.surface,
      shape: shape ?? _sheetShape,
      constraints: resolvedConstraints,
      builder: builder,
    );
  }

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
    return present<T>(
      context,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      showDragHandle: showDragHandle,
      isScrollControlled: heightFraction != null,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: _sheetShape,
      constraints: sheetConstraints(context),
      builder: (sheetContext) {
        if (builder != null) {
          return builder(sheetContext);
        }

        final asDialog = usesDialog(sheetContext);
        Widget sheet = AppBottomSheet(
          title: title,
          actions: actions,
          // Drag chrome is sheet-only; dialogs rely on title/actions.
          showDragHandle: asDialog ? false : showDragHandle,
          child: child,
        );

        if (heightFraction != null) {
          final height = MediaQuery.sizeOf(sheetContext).height * heightFraction;
          sheet = SizedBox(height: height, child: sheet);
        }

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
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
