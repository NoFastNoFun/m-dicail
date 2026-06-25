import 'package:flutter/material.dart';

extension MedicailThemeColors on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  Color get secondaryTextColor =>
      Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.65);

  Color get disabledTextColor =>
      Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.38);
}
