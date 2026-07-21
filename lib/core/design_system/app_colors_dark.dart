import 'package:flutter/material.dart';

import 'package:medicail/core/design_system/app_colors.dart';

abstract final class AppColorsDark {
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color primary = AppColors.white;
  static const Color onPrimary = AppColors.black;
  static const Color secondary = Color(0xFFB0B0B0);
  static const Color onSecondary = AppColors.black;
  static const Color border = Color(0xFF3A3A3A);
  static const Color disabled = Color(0xFF4A4A4A);
  static const Color onDisabled = Color(0xFF8A8A8A);

  static const Color error = Color(0xFFE32636);
  static const Color onError = AppColors.white;
  static const Color warning = Color(0xFFF8E823);
  static const Color onWarning = AppColors.black;
  static const Color success = Color(0xFFE0E0E0);
  static const Color onSuccess = AppColors.black;
  static const Color info = Color(0xFF2673E2);
  static const Color onInfo = AppColors.white;

  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textDisabled = Color(0xFF757575);
}
