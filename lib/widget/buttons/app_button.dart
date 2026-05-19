import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/app_typography.dart';
import 'package:medicail/widget/app_text.dart';

enum AppButtonStyle { primary, secondary, warning, error }

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
    final effectiveOnPressed =
        enabled && !isLoading ? onPressed : null;

    final child = isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _loadingColor(),
            ),
          )
        : _buildContent();

    final buttonStyle = _buttonStyle(expanded: expanded);

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

  Widget _buildContent() {
    return switch (layout) {
      AppButtonLayout.text => AppText(
          label!,
          variant: AppTextVariant.label,
          color: _foregroundColor(),
        ),
      AppButtonLayout.icon => Icon(icon, color: _foregroundColor(), size: 24),
      AppButtonLayout.textWithIcon => Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _foregroundColor(), size: 20),
            const SizedBox(width: AppSpacing.sm),
            AppText(
              label!,
              variant: AppTextVariant.label,
              color: _foregroundColor(),
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
    return OutlinedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: child,
    );
  }

  bool get _isFilledStyle =>
      style == AppButtonStyle.primary ||
      style == AppButtonStyle.warning ||
      style == AppButtonStyle.error;

  ButtonStyle _buttonStyle({required bool expanded}) {
    const minimumSize = Size(0, AppSpacing.minTouchTarget);
    final tapTarget = expanded
        ? MaterialTapTargetSize.padded
        : MaterialTapTargetSize.shrinkWrap;

    final (background, foreground, border) = switch (style) {
      AppButtonStyle.primary => (
          AppColors.primary,
          AppColors.onPrimary,
          AppColors.primary,
        ),
      AppButtonStyle.secondary => (
          Colors.transparent,
          AppColors.primary,
          AppColors.primary,
        ),
      AppButtonStyle.warning => (
          AppColors.warning,
          AppColors.onWarning,
          AppColors.warning,
        ),
      AppButtonStyle.error => (
          AppColors.error,
          AppColors.onError,
          AppColors.error,
        ),
    };

    if (_isFilledStyle) {
      return FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        disabledBackgroundColor: AppColors.disabled,
        disabledForegroundColor: AppColors.onDisabled,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
        textStyle: AppTypography.label,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        minimumSize: minimumSize,
        tapTargetSize: tapTarget,
      );
    }

    return OutlinedButton.styleFrom(
      foregroundColor: foreground,
      disabledForegroundColor: AppColors.textDisabled,
      side: BorderSide(color: border),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
      textStyle: AppTypography.label,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      minimumSize: minimumSize,
      tapTargetSize: tapTarget,
    );
  }

  Color _foregroundColor() {
    if (!enabled || isLoading) {
      return _isFilledStyle ? AppColors.onDisabled : AppColors.textDisabled;
    }
    return switch (style) {
      AppButtonStyle.primary => AppColors.onPrimary,
      AppButtonStyle.secondary => AppColors.primary,
      AppButtonStyle.warning => AppColors.onWarning,
      AppButtonStyle.error => AppColors.onError,
    };
  }

  Color _loadingColor() {
    return switch (style) {
      AppButtonStyle.primary => AppColors.onPrimary,
      AppButtonStyle.warning => AppColors.onWarning,
      AppButtonStyle.error => AppColors.onError,
      AppButtonStyle.secondary => AppColors.primary,
    };
  }
}
