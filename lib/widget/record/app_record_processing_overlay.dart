import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/widget/app_text.dart';

class AppRecordProcessingOverlay extends StatefulWidget {
  const AppRecordProcessingOverlay({
    super.key,
    required this.isTranscribingBackground,
    required this.isEnhancing,
  });

  final bool isTranscribingBackground;
  final bool isEnhancing;

  @override
  State<AppRecordProcessingOverlay> createState() =>
      _AppRecordProcessingOverlayState();
}

class _AppRecordProcessingOverlayState extends State<AppRecordProcessingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isEnhancing) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AppRecordProcessingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnhancing && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isEnhancing && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final String message = widget.isTranscribingBackground
        ? l10n.recordStatusTranscribingBackground
        : widget.isEnhancing
            ? l10n.recordStatusEnhancing
            : l10n.recordStatusGeneratingSOAP;

    return Container(
      color: AppColors.highContrastBlack.withValues(alpha: 0.54),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isEnhancing)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final t = _pulseController.value;
                  return SizedBox(
                    width: 96,
                    height: 96,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.scale(
                          scale: 0.85 + (t * 0.25),
                          child: Icon(
                            Icons.auto_awesome,
                            size: 42,
                            color: AppColors.highContrastWhite
                                .withValues(alpha: 0.35 + (t * 0.45)),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 14,
                          child: Opacity(
                            opacity: 0.4 + (t * 0.6),
                            child: const Icon(
                              Icons.auto_awesome,
                              size: 18,
                              color: AppColors.highContrastWhite,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 10,
                          child: Opacity(
                            opacity: 0.7 - (t * 0.4),
                            child: const Icon(
                              Icons.auto_awesome_outlined,
                              size: 16,
                              color: AppColors.highContrastWhite,
                            ),
                          ),
                        ),
                        child!,
                      ],
                    ),
                  );
                },
                child: const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.highContrastWhite,
                  ),
                ),
              )
            else
              const CircularProgressIndicator(
                color: AppColors.highContrastWhite,
              ),
            const SizedBox(height: AppSpacing.md),
            AppText(
              message,
              variant: AppTextVariant.body,
              color: AppColors.highContrastWhite,
            ),
          ],
        ),
      ),
    );
  }
}
