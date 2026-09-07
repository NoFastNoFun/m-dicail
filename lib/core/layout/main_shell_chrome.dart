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

  static double navPillHeight(BuildContext context) {
    // Two padding layers, an icon, a gap and space for accessible labels.
    return (AppSpacing.xs * 4 +
            navIconSize +
            AppSpacing.xs +
            navLabelHeight(context))
        .clamp(72.0, double.infinity);
  }
}

class MainShellScope extends InheritedWidget {
  const MainShellScope({
    required super.child,
    required this.bottomPadding,
    super.key,
  });

  final double bottomPadding;

  static MainShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainShellScope>();
  }

  static bool isActive(BuildContext context) => maybeOf(context) != null;

  EdgeInsets scrollPadding() {
    return EdgeInsets.only(bottom: bottomPadding);
  }

  static EdgeInsets scrollPaddingOf(BuildContext context) {
    return maybeOf(context)?.scrollPadding() ?? EdgeInsets.zero;
  }

  @override
  bool updateShouldNotify(MainShellScope oldWidget) {
    return bottomPadding != oldWidget.bottomPadding;
  }
}
