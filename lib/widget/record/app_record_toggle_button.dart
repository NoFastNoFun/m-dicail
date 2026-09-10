import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';

class AppRecordToggleButton extends StatelessWidget {
  const AppRecordToggleButton({
    super.key,
    required this.isRecording,
    required this.onPressed,
    this.enabled = true,
    this.isLoading = false,
    this.isAiActive = false,
  });

  final bool isRecording;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool isLoading;
  final bool isAiActive;

  static const double _height = 52;
  static const double _iconSize = 18;
  static const double _sparkleSize = 20;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveOnPressed = enabled && !isLoading ? onPressed : null;
    final useAiStyle = isAiActive && enabled;

    final backgroundColor = enabled
        ? AppColors.error
        : theme.colorScheme.surfaceContainerHighest;

    final content = SizedBox(
      height: _height,
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.onError,
                ),
              )
            : _RecordIcon(
                isRecording: isRecording,
                enabled: enabled,
                showSparkle: useAiStyle,
              ),
      ),
    );

    if (useAiStyle) {
      return Material(
        color: Colors.transparent,
        borderRadius: AppRadius.pillBorder,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: effectiveOnPressed,
          borderRadius: AppRadius.pillBorder,
          child: Ink(
            decoration: const BoxDecoration(
              gradient: AppGradients.ai,
              borderRadius: AppRadius.pillBorder,
            ),
            child: content,
          ),
        ),
      );
    }

    return Material(
      color: backgroundColor,
      borderRadius: AppRadius.pillBorder,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: effectiveOnPressed,
        borderRadius: AppRadius.pillBorder,
        child: content,
      ),
    );
  }
}

class _RecordIcon extends StatelessWidget {
  const _RecordIcon({
    required this.isRecording,
    this.enabled = true,
    this.showSparkle = false,
  });

  final bool isRecording;
  final bool enabled;
  final bool showSparkle;

  @override
  Widget build(BuildContext context) {
    final glyphColor = enabled
        ? AppColors.onError
        : Theme.of(context).disabledColor;

    final glyph = isRecording
        ? Container(
            width: AppRecordToggleButton._iconSize,
            height: AppRecordToggleButton._iconSize,
            decoration: BoxDecoration(
              color: enabled
                  ? AppColors.onError.withValues(alpha: 0.85)
                  : Theme.of(context).disabledColor,
              borderRadius: BorderRadius.circular(
                AppRecordToggleButton._iconSize / 2,
              ),
            ),
          )
        : Container(
            width: AppRecordToggleButton._iconSize,
            height: AppRecordToggleButton._iconSize,
            decoration: BoxDecoration(
              color: glyphColor,
              shape: BoxShape.circle,
            ),
          );

    if (!showSparkle) {
      return glyph;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.auto_awesome,
          size: AppRecordToggleButton._sparkleSize,
          color: AppColors.onError,
        ),
        const SizedBox(width: AppSpacing.sm),
        glyph,
      ],
    );
  }
}
