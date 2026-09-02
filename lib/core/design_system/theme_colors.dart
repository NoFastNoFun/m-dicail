import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';

extension MedicailThemeColors on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  Color get secondaryTextColor =>
      Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.65);

  Color get disabledTextColor =>
      Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.38);
}

extension MedicailHighContrastTheme on ThemeData {
  ThemeData get highContrastSurface {
    final isDark = brightness == Brightness.dark;
    final bg =
        isDark ? AppColors.highContrastBlack : AppColors.highContrastWhite;
    final fg =
        isDark ? AppColors.highContrastWhite : AppColors.highContrastBlack;

    return withOnboardingShapes.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: colorScheme.copyWith(
        onSurface: fg,
        primary: fg,
        onPrimary: bg,
        surface: isDark ? const Color(0xFF1A1A1A) : AppColors.surface,
      ),
      textTheme: textTheme.apply(
        bodyColor: fg,
        displayColor: fg,
      ),
    );
  }

  /// One UI 7/8-style auth surfaces: soft filled fields, large radii,
  /// theme-aware colors (no forced white page).
  ThemeData get authSurface {
    final pageBg = scaffoldBackgroundColor;
    final fieldFill = Color.alphaBlend(
      colorScheme.onSurface.withValues(
        alpha: brightness == Brightness.dark ? 0.12 : 0.06,
      ),
      pageBg,
    );
    final softBorder = OutlineInputBorder(
      borderRadius: AppRadius.xxlBorder,
      borderSide: BorderSide.none,
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: AppRadius.xxlBorder,
      borderSide: BorderSide(color: colorScheme.primary, width: 2),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: AppRadius.xxlBorder,
      borderSide: BorderSide(color: colorScheme.error, width: 1.5),
    );
    final focusedErrorBorder = OutlineInputBorder(
      borderRadius: AppRadius.xxlBorder,
      borderSide: BorderSide(color: colorScheme.error, width: 2),
    );

    return copyWith(
      inputDecorationTheme: inputDecorationTheme.copyWith(
        filled: true,
        fillColor: fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg + 2,
        ),
        border: softBorder,
        enabledBorder: softBorder,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: focusedErrorBorder,
        disabledBorder: softBorder,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: AppRadius.pillShape,
        ).merge(filledButtonTheme.style),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: AppRadius.pillShape,
        ).merge(outlinedButtonTheme.style),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, AppSpacing.minTouchTarget),
          shape: AppRadius.pillShape,
        ).merge(textButtonTheme.style),
      ),
    );
  }

  /// Softened radii for tutorial/onboarding UI (buttons stay rectangular here).
  ThemeData get withOnboardingShapes {
    final inputTheme = inputDecorationTheme;
    final borderSide = inputTheme.enabledBorder?.borderSide ??
        BorderSide(color: dividerColor);
    final focusedSide = inputTheme.focusedBorder?.borderSide ??
        BorderSide(color: colorScheme.primary, width: 2);
    final errorSide = inputTheme.errorBorder?.borderSide ??
        BorderSide(color: colorScheme.error);
    final focusedErrorSide = inputTheme.focusedErrorBorder?.borderSide ??
        BorderSide(color: colorScheme.error, width: 2);
    final disabledSide = inputTheme.disabledBorder?.borderSide ??
        BorderSide(color: disabledColor);

    OutlineInputBorder outline(BorderSide side) => OutlineInputBorder(
          borderRadius: AppRadius.onboardingMdBorder,
          borderSide: side,
        );

    return copyWith(
      inputDecorationTheme: inputTheme.copyWith(
        border: outline(borderSide),
        enabledBorder: outline(borderSide),
        focusedBorder: outline(focusedSide),
        errorBorder: outline(errorSide),
        focusedErrorBorder: outline(focusedErrorSide),
        disabledBorder: outline(disabledSide),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppSpacing.minTouchTarget),
          shape: AppRadius.onboardingMdShape,
        ).merge(filledButtonTheme.style),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppSpacing.minTouchTarget),
          shape: AppRadius.onboardingMdShape,
        ).merge(outlinedButtonTheme.style),
      ),
      dialogTheme: dialogTheme.copyWith(
        shape: AppRadius.onboardingMdShape,
      ),
      bottomSheetTheme: bottomSheetTheme.copyWith(
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.onboardingLgBorder,
        ),
      ),
    );
  }
}
