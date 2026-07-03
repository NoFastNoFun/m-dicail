import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_spacing.dart';

abstract final class MainShellChrome {
  static const double height = 140;
  static const double navLift = AppSpacing.lg;

  static double bottomInset(BuildContext context) {
    return height + MediaQuery.viewPaddingOf(context).bottom;
  }

  static EdgeInsets scrollPadding(BuildContext context) {
    return EdgeInsets.only(bottom: bottomInset(context));
  }
}

class MainShellScope extends InheritedWidget {
  const MainShellScope({required super.child, super.key});

  static bool isActive(BuildContext context) {
    return context.getInheritedWidgetOfExactType<MainShellScope>() != null;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
