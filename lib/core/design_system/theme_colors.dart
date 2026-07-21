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
  /// Onboarding/auth surfaces that need true black-on-white readability.
  ThemeData get highContrastSurface {
    return withOnboardingShapes.copyWith(
      scaffoldBackgroundColor: AppColors.highContrastWhite,
      colorScheme: colorScheme.copyWith(
        onSurface: AppColors.highContrastBlack,
        primary: AppColors.highContrastBlack,
        onPrimary: AppColors.highContrastWhite,
      ),
      textTheme: textTheme.apply(
        bodyColor: AppColors.highContrastBlack,
        displayColor: AppColors.highContrastBlack,
      ),
    );
  }

  /// Squircle radii for tutorial/onboarding UI that should not use global pills.
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
