import 'package:flutter/material.dart';

/// Centralized color palette. Edit here to update the app globally.
abstract final class AppColors {
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color primary = Color(0xFF000000);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF616161);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0E0E0);
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color onDisabled = Color(0xFF757575);

  static const Color error = Color(0xFFE32636);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFF8E823);
  static const Color onWarning = Color(0xFF000000);
  static const Color success = Color(0xFF303030);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color info = Color(0xFF2673E2);
  static const Color onInfo = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textDisabled = Color(0xFF9E9E9E);
}
