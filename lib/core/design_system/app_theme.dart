import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_colors_dark.dart';
import 'package:medicail/core/design_system/app_colors_solarized.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/features/settings/domain/entities/app_theme_variant.dart';

abstract final class AppTheme {
  static ThemeData forVariant(AppThemeVariant variant) {
    return switch (variant) {
      AppThemeVariant.light => light,
      AppThemeVariant.dark => dark,
      AppThemeVariant.solarized => solarized,
    };
  }

  static ThemeData get light => _buildTheme(
        brightness: Brightness.light,
        background: AppColors.background,
        surface: AppColors.surface,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.onError,
        border: AppColors.border,
        disabled: AppColors.disabled,
        onDisabled: AppColors.onDisabled,
        textPrimary: AppColors.textPrimary,
        textSecondary: AppColors.textSecondary,
        textDisabled: AppColors.textDisabled,
      );

  static ThemeData get dark => _buildTheme(
        brightness: Brightness.dark,
        background: AppColorsDark.background,
        surface: AppColorsDark.surface,
        primary: AppColorsDark.primary,
        onPrimary: AppColorsDark.onPrimary,
        secondary: AppColorsDark.secondary,
        onSecondary: AppColorsDark.onSecondary,
        onSurface: AppColorsDark.textPrimary,
        error: AppColorsDark.error,
        onError: AppColorsDark.onError,
        border: AppColorsDark.border,
        disabled: AppColorsDark.disabled,
        onDisabled: AppColorsDark.onDisabled,
        textPrimary: AppColorsDark.textPrimary,
        textSecondary: AppColorsDark.textSecondary,
        textDisabled: AppColorsDark.textDisabled,
      );

  static ThemeData get solarized => _buildTheme(
        brightness: Brightness.light,
        background: AppColorsSolarized.background,
        surface: AppColorsSolarized.surface,
        primary: AppColorsSolarized.primary,
        onPrimary: AppColorsSolarized.onPrimary,
        secondary: AppColorsSolarized.secondary,
        onSecondary: AppColorsSolarized.onSecondary,
        onSurface: AppColorsSolarized.textPrimary,
        error: AppColorsSolarized.error,
        onError: AppColorsSolarized.onError,
        border: AppColorsSolarized.border,
        disabled: AppColorsSolarized.disabled,
        onDisabled: AppColorsSolarized.onDisabled,
        textPrimary: AppColorsSolarized.textPrimary,
        textSecondary: AppColorsSolarized.textSecondary,
        textDisabled: AppColorsSolarized.textDisabled,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color primary,
    required Color onPrimary,
    required Color secondary,
    required Color onSecondary,
    required Color onSurface,
    required Color error,
    required Color onError,
    required Color border,
    required Color disabled,
    required Color onDisabled,
    required Color textPrimary,
    required Color textSecondary,
    required Color textDisabled,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      surface: surface,
      onSurface: onSurface,
      error: error,
      onError: onError,
    );

    final textTheme = TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.25,
        color: textPrimary,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        height: 1.3,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
        color: textPrimary,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
        color: textPrimary,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
        color: textPrimary,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.35,
        color: textSecondary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleMedium,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: BorderSide(color: error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: BorderSide(color: disabled),
        ),
        labelStyle: textTheme.labelLarge?.copyWith(color: textSecondary),
        hintStyle: textTheme.bodyLarge?.copyWith(color: textDisabled),
        errorStyle: textTheme.bodySmall?.copyWith(color: error),
      ),
      // Size.fromHeight sets width to infinity and breaks TextButton + Expanded rows.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppSpacing.minTouchTarget),
          backgroundColor: primary,
          foregroundColor: onPrimary,
          disabledBackgroundColor: disabled,
          disabledForegroundColor: onDisabled,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppSpacing.minTouchTarget),
          foregroundColor: primary,
          disabledForegroundColor: textDisabled,
          side: BorderSide(color: primary),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, AppSpacing.minTouchTarget),
          foregroundColor: primary,
          disabledForegroundColor: textDisabled,
          textStyle: textTheme.labelLarge,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: background,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
        titleTextStyle: textTheme.titleMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
        showDragHandle: true,
      ),
      dividerColor: border,
      disabledColor: disabled,
    );
  }
}
