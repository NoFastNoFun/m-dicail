import 'package:flutter/material.dart';

/// Centralized color palette. Edit here to update the app globally.
abstract final class AppColors {
  static const Color black = Color(0xFF222222);
  static const Color white = Color(0xFFE9E9E9);

  /// Full-contrast pair for overlays and onboarding surfaces.
  static const Color highContrastBlack = Color(0xFF000000);
  static const Color highContrastWhite = Color(0xFFFFFFFF);

  static const Color background = white;
  static const Color surface = Color(0xFFF5F5F5);
  static const Color primary = black;
  static const Color onPrimary = white;
  static const Color secondary = Color(0xFF616161);
  static const Color onSecondary = white;
  static const Color border = Color(0xFFE0E0E0);
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color onDisabled = Color(0xFF757575);

  static const Color error = Color(0xFFE32636);
  static const Color onError = white;
  static const Color warning = Color(0xFFF8E823);
  static const Color onWarning = black;
  static const Color success = Color(0xFF303030);
  static const Color onSuccess = white;
  static const Color info = Color(0xFF2673E2);
  static const Color onInfo = white;

  static const Color textPrimary = black;
  static const Color textSecondary = Color(0xFF616161);
  static const Color textDisabled = Color(0xFF9E9E9E);
}
