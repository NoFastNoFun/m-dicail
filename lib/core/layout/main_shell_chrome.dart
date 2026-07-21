import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_spacing.dart';

abstract final class MainShellChrome {
  static const double fabHeight = 56;
  static const double fabNavGap = AppSpacing.sm;
  static const double navPillHeightWithLabels = 72;
  static const double navPillHeightCompact = 44;
  static const double navLift = AppSpacing.xl;

  static double navPillHeight({required bool labelsVisible}) {
    return labelsVisible ? navPillHeightWithLabels : navPillHeightCompact;
  }

  static double overlayHeight({required bool labelsVisible}) {
    return fabHeight + fabNavGap + navPillHeight(labelsVisible: labelsVisible);
  }

  static double scrollBottomPadding(
    BuildContext context, {
    required bool labelsVisible,
  }) {
    final viewPadding = MediaQuery.viewPaddingOf(context).bottom;
    return navLift +
        navPillHeight(labelsVisible: labelsVisible) +
        viewPadding +
        AppSpacing.sm;
  }

  static EdgeInsets scrollPadding(
    BuildContext context, {
    required bool labelsVisible,
  }) {
    return EdgeInsets.only(
      bottom: scrollBottomPadding(context, labelsVisible: labelsVisible),
    );
  }
}

class MainShellScope extends InheritedWidget {
  const MainShellScope({
    required this.navLabelsVisible,
    required super.child,
    super.key,
  });

  final bool navLabelsVisible;

  static MainShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainShellScope>();
  }

  static bool isActive(BuildContext context) => maybeOf(context) != null;

  EdgeInsets scrollPadding(BuildContext context) {
    return MainShellChrome.scrollPadding(
      context,
      labelsVisible: navLabelsVisible,
    );
  }

  static EdgeInsets scrollPaddingOf(BuildContext context) {
    return maybeOf(context)?.scrollPadding(context) ?? EdgeInsets.zero;
  }

  @override
  bool updateShouldNotify(MainShellScope oldWidget) {
    return navLabelsVisible != oldWidget.navLabelsVisible;
  }
}
