import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_typography.dart';
import 'package:medicail/core/design_system/app_spacing.dart';

abstract final class MainShellChrome {
  static const double fabHeight = 56;
  static const double fabNavGap = AppSpacing.sm;
  static const double navIconSize = 22;
  static const int navLabelMaxLines = 2;
  static const double navLift = AppSpacing.xl;
  static const double sideRailWidth = 88;

  static double navLabelHeight(BuildContext context) {
    final style = AppTypography.navigation;
    return (MediaQuery.textScalerOf(context).scale(style.fontSize!) *
            style.height! *
            navLabelMaxLines)
        .ceilToDouble();
  }

  static double navPillHeight(BuildContext context, {bool showLabels = true}) {
    // Two padding layers, an icon, a gap and space for accessible labels.
    final labelSpace = showLabels ? navLabelHeight(context) : 0.0;
    return (AppSpacing.xs * 4 + navIconSize + labelSpace)
        .clamp(showLabels ? 72.0 : 48.0, double.infinity);
  }
}

class MainShellScope extends InheritedWidget {
  const MainShellScope({
    required this.registerFabPrimaryAction,
    required super.child,
    required this.bottomPadding,
    super.key,
  });

  final double bottomPadding;

  /// Registers a page-specific FAB tap action. Pass null to clear.
  /// When set, FAB tap runs this action and long-press opens the radial menu.
  final void Function(VoidCallback? action) registerFabPrimaryAction;

  static MainShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainShellScope>();
  }

  static bool isActive(BuildContext context) => maybeOf(context) != null;

  static void setFabPrimaryAction(BuildContext context, VoidCallback? action) {
    maybeOf(context)?.registerFabPrimaryAction(action);
  }

  EdgeInsets scrollPadding() {
    return EdgeInsets.only(bottom: bottomPadding);
  }

  static EdgeInsets scrollPaddingOf(BuildContext context) {
    return maybeOf(context)?.scrollPadding() ?? EdgeInsets.zero;
  }

  @override
  bool updateShouldNotify(MainShellScope oldWidget) {
    return bottomPadding != oldWidget.bottomPadding ||
        registerFabPrimaryAction != oldWidget.registerFabPrimaryAction;
  }
}
