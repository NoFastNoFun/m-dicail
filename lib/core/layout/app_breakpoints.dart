import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_spacing.dart';

/// Width breakpoints and content caps for responsive layouts.
///
/// Mobile layouts stay full-bleed. From [medium] upward, content is capped and
/// the main shell switches to a side navigation rail.
abstract final class AppBreakpoints {
  static const double compact = 600;
  static const double medium = 900;
  static const double expanded = 1200;

  /// Reading / list column width on tablet and desktop.
  static const double contentMaxWidth = 880;

  /// Wide pages that benefit from a bit more horizontal room (e.g. record).
  static const double wideContentMaxWidth = 1040;

  /// Auth and dense forms.
  static const double formMaxWidth = 440;

  /// Modal sheets on large screens.
  static const double sheetMaxWidth = 560;
}

abstract final class AppLayout {
  static Size sizeOf(BuildContext context) => MediaQuery.sizeOf(context);

  static double widthOf(BuildContext context) => sizeOf(context).width;

  static bool isCompact(BuildContext context) =>
      widthOf(context) < AppBreakpoints.compact;

  static bool isMedium(BuildContext context) {
    final width = widthOf(context);
    return width >= AppBreakpoints.compact && width < AppBreakpoints.medium;
  }

  static bool isExpanded(BuildContext context) =>
      widthOf(context) >= AppBreakpoints.medium;

  /// Side rail instead of the floating bottom nav pill.
  static bool useSideNavigation(BuildContext context) => isExpanded(context);

  static double contentMaxWidth(BuildContext context, {double? maxWidth}) {
    final width = widthOf(context);
    if (width < AppBreakpoints.compact) {
      return width;
    }
    return maxWidth ?? AppBreakpoints.contentMaxWidth;
  }

  static EdgeInsets pagePadding(BuildContext context) {
    final width = widthOf(context);
    if (width >= AppBreakpoints.expanded) {
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xl,
      );
    }
    if (width >= AppBreakpoints.compact) {
      return const EdgeInsets.all(AppSpacing.xl);
    }
    return const EdgeInsets.all(AppSpacing.pagePadding);
  }

  /// Patient / card grids: 1 on phone, 2 on tablet, 3 on wide desktop.
  static int gridColumnCount(
    BuildContext context, {
    double minTileWidth = 280,
  }) {
    final width = widthOf(context);
    if (width < AppBreakpoints.compact) {
      return 1;
    }
    final usable = useSideNavigation(context)
        ? (width - 88).clamp(0.0, AppBreakpoints.contentMaxWidth)
        : width.clamp(0.0, AppBreakpoints.contentMaxWidth);
    return (usable / minTileWidth).floor().clamp(1, 3);
  }
}
