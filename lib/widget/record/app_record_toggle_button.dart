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
    final effectiveOnPressed = enabled && !isLoading ? onPressed : null;

    return Material(
      color: AppColors.error,
      borderRadius: AppRadius.mdBorder,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: effectiveOnPressed,
        borderRadius: AppRadius.mdBorder,
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
                : _RecordIcon(isRecording: isRecording),
          ),
        ),
      ),
    );
  }
}

class _RecordIcon extends StatelessWidget {
  const _RecordIcon({required this.isRecording});

  final bool isRecording;

  @override
  Widget build(BuildContext context) {
    if (isRecording) {
      return Container(
        width: AppRecordToggleButton._iconSize,
        height: AppRecordToggleButton._iconSize,
        decoration: BoxDecoration(
          color: AppColors.onError.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(AppRecordToggleButton._iconSize / 2),
        ),
      );
    }

    return Container(
      width: AppRecordToggleButton._iconSize,
      height: AppRecordToggleButton._iconSize,
      decoration: const BoxDecoration(
        color: AppColors.onError,
        shape: BoxShape.circle,
      ),
    );
  }
}
