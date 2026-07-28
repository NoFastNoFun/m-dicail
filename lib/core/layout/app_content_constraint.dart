import 'package:flutter/material.dart';
import 'package:medicail/core/layout/app_breakpoints.dart';

/// Centers [child] and caps its width on tablet/desktop.
///
/// Uses [SizedBox] width infinity under a max constraint so columns with
/// [CrossAxisAlignment.stretch] still fill the capped content lane.
class AppContentConstraint extends StatelessWidget {
  const AppContentConstraint({
    super.key,
    required this.child,
    this.maxWidth,
    this.alignment = Alignment.topCenter,
    this.applyPagePadding = false,
  });

  final Widget child;
  final double? maxWidth;
  final Alignment alignment;
  final bool applyPagePadding;

  @override
  Widget build(BuildContext context) {
    final cappedWidth = AppLayout.contentMaxWidth(context, maxWidth: maxWidth);

    Widget content = child;
    if (applyPagePadding) {
      content = Padding(
        padding: AppLayout.pagePadding(context),
        child: content,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final width = !maxW.isFinite || maxW <= 0
            ? cappedWidth
            : maxW.clamp(0.0, cappedWidth);

        return Align(
          alignment: alignment,
          child: SizedBox(width: width, child: content),
        );
      },
    );
  }
}

/// Narrower constraint for auth / settings-style forms.
class AppFormConstraint extends StatelessWidget {
  const AppFormConstraint({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppContentConstraint(
      maxWidth: AppBreakpoints.formMaxWidth,
      alignment: Alignment.center,
      child: child,
    );
  }
}
