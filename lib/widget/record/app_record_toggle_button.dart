import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';

class AppRecordToggleButton extends StatelessWidget {
  const AppRecordToggleButton({
    super.key,
    required this.isRecording,
    required this.onPressed,
    this.enabled = true,
    this.isLoading = false,
  });

  final bool isRecording;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool isLoading;

  static const double _height = 52;
  static const double _iconSize = 18;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveOnPressed = enabled && !isLoading ? onPressed : null;
    
    final backgroundColor = enabled 
        ? AppColors.error 
        : theme.colorScheme.surfaceContainerHighest;

    return Material(
      color: backgroundColor,
      borderRadius: AppRadius.pillBorder,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: effectiveOnPressed,
        borderRadius: AppRadius.pillBorder,
        child: SizedBox(
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
                : _RecordIcon(isRecording: isRecording, enabled: enabled),
          ),
        ),
      ),
    );
  }
}

class _RecordIcon extends StatelessWidget {
  const _RecordIcon({required this.isRecording, this.enabled = true});

  final bool isRecording;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (isRecording) {
      return Container(
        width: AppRecordToggleButton._iconSize,
        height: AppRecordToggleButton._iconSize,
        decoration: BoxDecoration(
          color: enabled 
              ? AppColors.onError.withValues(alpha: 0.85)
              : Theme.of(context).disabledColor,
          borderRadius: BorderRadius.circular(AppRecordToggleButton._iconSize / 2),
        ),
      );
    }

    return Container(
      width: AppRecordToggleButton._iconSize,
      height: AppRecordToggleButton._iconSize,
      decoration: BoxDecoration(
        color: enabled ? AppColors.onError : Theme.of(context).disabledColor,
        shape: BoxShape.circle,
      ),
    );
  }
}
