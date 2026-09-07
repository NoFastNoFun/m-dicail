import 'package:flutter/material.dart';

/// Curated swatches for the custom theme. Contrast is intentional for light and dark UIs.
abstract final class AppCustomThemePalettes {
  static const List<Color> primaryLight = [
    Color(0xFFF4A7B9), // blush
    Color(0xFFF5C6A5), // peach
    Color(0xFFB8E0D2), // mint
    Color(0xFFC9B8E8), // lavender
    Color(0xFFA8D4F0), // sky
    Color(0xFFC4A832), // mustard
  ];

  static const List<Color> primaryDark = [
    Color(0xFFE5738A), // rose
    Color(0xFFE09A6A), // terracotta
    Color(0xFF6BBFA8), // teal
    Color(0xFF9B7EC8), // violet
    Color(0xFF5BA3D9), // azure
    Color(0xFFD4A017), // gold
  ];

  static const List<Color> backgroundsLight = [
    Color(0xFFFAFAF8), // warm white
    Color(0xFFF2F2F0), // soft gray
    Color(0xFFFDF8F0), // cream
    Color(0xFFF0F4F8), // pale blue-gray
    Color(0xFFF2F6F2), // pale sage
  ];

  static const List<Color> backgroundsDark = [
    Color(0xFF121212), // charcoal
    Color(0xFF1A1A1E), // ink
    Color(0xFF1C1917), // warm black
    Color(0xFF141A1F), // navy black
    Color(0xFF161A16), // forest black
  ];

  /// Pastels plus deeper accents suitable for dark backgrounds.
  static const List<Color> primaryPastels = [
    ...primaryLight,
    ...primaryDark,
  ];

  static const List<Color> backgrounds = [
    ...backgroundsLight,
    ...backgroundsDark,
  ];

  static Color get defaultPrimary => primaryLight.first;

  static Color get defaultBackground => backgroundsLight.first;

  static Color resolvePrimary(Color? value) {
    if (value == null) {
      return defaultPrimary;
    }
    final valueArgb = value.toARGB32();
    for (final swatch in primaryPastels) {
      if (swatch.toARGB32() == valueArgb) {
        return swatch;
      }
    }
    return defaultPrimary;
  }

  static Color resolveBackground(Color? value) {
    if (value == null) {
      return defaultBackground;
    }
    final valueArgb = value.toARGB32();
    for (final swatch in backgrounds) {
      if (swatch.toARGB32() == valueArgb) {
        return swatch;
      }
    }
    return defaultBackground;
  }

  static bool isDarkBackground(Color background) {
    return background.computeLuminance() < 0.35;
  }
}
