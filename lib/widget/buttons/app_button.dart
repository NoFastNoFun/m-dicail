import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/app_typography.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/widget/app_text.dart';

enum AppButtonStyle { primary, secondary, tertiary, warning, error, info }

enum AppButtonLayout { text, icon, textWithIcon }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    this.style = AppButtonStyle.primary,
    this.layout = AppButtonLayout.text,
    this.label,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
    this.expanded = true,
  })  : assert(
          layout != AppButtonLayout.text || label != null,
          'label is required for text layout',
        ),
        assert(
          layout == AppButtonLayout.text || icon != null,
          'icon is required for icon and textWithIcon layouts',
        ),
        assert(
          layout != AppButtonLayout.textWithIcon ||
              (label != null && icon != null),
          'label and icon are required for textWithIcon layout',
        );

  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final AppButtonLayout layout;
  final String? label;
  final IconData? icon;
  final bool isLoading;
  final bool enabled;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    final effectiveOnPressed = enabled && !isLoading && onPressed != null
        ? () {
            FocusManager.instance.primaryFocus?.unfocus();
            onPressed!();
          }
        : null;

    final child = isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _loadingColor(colorScheme),
            ),
          )
        : _buildContent(colorScheme);

    final buttonStyle = _buttonStyle(context, colorScheme, expanded: expanded);

    return switch (layout) {
      AppButtonLayout.text => _wrapSized(
          _textButton(child, effectiveOnPressed, buttonStyle),
        ),
      AppButtonLayout.icon => _wrapSized(
          _iconButton(child, effectiveOnPressed, buttonStyle),
        ),
      AppButtonLayout.textWithIcon => _wrapSized(
          _textButton(child, effectiveOnPressed, buttonStyle),
        ),
    };
  }

  Widget _buildContent(ColorScheme colorScheme) {
    return switch (layout) {
      AppButtonLayout.text => AppText(
          label!,
          variant: AppTextVariant.label,
          color: _foregroundColor(colorScheme),
        ),
      AppButtonLayout.icon => Icon(icon, color: _foregroundColor(colorScheme), size: 24),
      AppButtonLayout.textWithIcon => Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _foregroundColor(colorScheme), size: 20),
            const SizedBox(width: AppSpacing.sm),
            AppText(
              label!,
              variant: AppTextVariant.label,
              color: _foregroundColor(colorScheme),
            ),
          ],
        ),
    };
  }

  Widget _wrapSized(Widget child) {
    if (layout == AppButtonLayout.icon) {
      return SizedBox(
        height: AppSpacing.minTouchTarget,
        width: AppSpacing.minTouchTarget,
        child: child,
      );
    }
    if (!expanded) {
      return IntrinsicWidth(
        child: SizedBox(
          height: AppSpacing.minTouchTarget,
          child: child,
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.minTouchTarget,
      child: child,
    );
  }

  Widget _textButton(
    Widget child,
    VoidCallback? onPressed,
    ButtonStyle buttonStyle,
  ) {
    if (_isFilledStyle) {
      return FilledButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: child,
      );
    }
    if (style == AppButtonStyle.tertiary) {
      return TextButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: child,
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: child,
    );
  }

  Widget _iconButton(
    Widget child,
    VoidCallback? onPressed,
    ButtonStyle buttonStyle,
  ) {
    if (_isFilledStyle) {
      return FilledButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: child,
      );
    }
    if (style == AppButtonStyle.tertiary) {
      return TextButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: child,
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: child,
    );
  }

  bool get _isFilledStyle =>
      style == AppButtonStyle.primary ||
      style == AppButtonStyle.warning ||
      style == AppButtonStyle.error ||
      style == AppButtonStyle.info;

  RoundedRectangleBorder _resolveButtonShape(BuildContext context) {
    final themeStyle = _isFilledStyle
        ? Theme.of(context).filledButtonTheme.style
        : style == AppButtonStyle.tertiary 
            ? Theme.of(context).textButtonTheme.style
            : Theme.of(context).outlinedButtonTheme.style;
    final resolved = themeStyle?.shape?.resolve(const {});
    if (resolved is RoundedRectangleBorder) {
      final radius = resolved.borderRadius.resolve(Directionality.of(context));
      if (radius.topLeft.x < AppRadius.pill) {
        return resolved;
      }
    }
    return AppRadius.pillShape;
  }

  ButtonStyle _buttonStyle(
    BuildContext context,
    ColorScheme colorScheme, {
    required bool expanded,
  }) {
    const minimumSize = Size(0, AppSpacing.minTouchTarget);
    final tapTarget = expanded
        ? MaterialTapTargetSize.padded
        : MaterialTapTargetSize.shrinkWrap;
    final labelStyle =
        AppTypography.label.copyWith(color: _foregroundColor(colorScheme));

    final (background, foreground, border) = switch (style) {
      AppButtonStyle.primary => (
          colorScheme.primary,
          colorScheme.onPrimary,
          colorScheme.primary,
        ),
      AppButtonStyle.secondary => (
          Colors.transparent,
          colorScheme.primary,
          colorScheme.primary,
        ),
      AppButtonStyle.tertiary => (
          Colors.transparent,
          colorScheme.primary,
          Colors.transparent,
        ),
      AppButtonStyle.warning => (
          AppColors.warning,
          AppColors.onWarning,
          AppColors.warning,
        ),
      AppButtonStyle.error => (
          colorScheme.error,
          colorScheme.onError,
          colorScheme.error,
        ),
      AppButtonStyle.info => (
          AppColors.info,
          AppColors.onInfo,
          AppColors.info,
        ),
    };

    final shape = _resolveButtonShape(context);

    if (_isFilledStyle) {
      return FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        shape: shape,
        textStyle: labelStyle,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        minimumSize: minimumSize,
        tapTargetSize: tapTarget,
      );
    }
    
    if (style == AppButtonStyle.tertiary) {
      return TextButton.styleFrom(
        foregroundColor: foreground,
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        shape: shape,
        textStyle: labelStyle,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        minimumSize: minimumSize,
        tapTargetSize: tapTarget,
      );
    }

    return OutlinedButton.styleFrom(
      foregroundColor: foreground,
      disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
      side: BorderSide(color: border),
      shape: shape,
      textStyle: labelStyle,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      minimumSize: minimumSize,
      tapTargetSize: tapTarget,
    );
  }

  Color _foregroundColor(ColorScheme colorScheme) {
    if (!enabled || isLoading) {
      return _isFilledStyle
          ? colorScheme.onSurface.withValues(alpha: 0.38)
          : colorScheme.onSurface.withValues(alpha: 0.38);
    }
    return switch (style) {
      AppButtonStyle.primary => colorScheme.onPrimary,
      AppButtonStyle.secondary => colorScheme.primary,
      AppButtonStyle.tertiary => colorScheme.primary,
      AppButtonStyle.warning => AppColors.onWarning,
      AppButtonStyle.error => colorScheme.onError,
      AppButtonStyle.info => AppColors.onInfo,
    };
  }

  Color _loadingColor(ColorScheme colorScheme) {
    return switch (style) {
      AppButtonStyle.primary => colorScheme.onPrimary,
      AppButtonStyle.warning => AppColors.onWarning,
      AppButtonStyle.error => colorScheme.onError,
      AppButtonStyle.info => AppColors.onInfo,
      AppButtonStyle.secondary => colorScheme.primary,
      AppButtonStyle.tertiary => colorScheme.primary,
    };
  }
}
