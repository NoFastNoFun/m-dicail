import 'dart:math' as math;

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
  late final AnimationController _controller;

  bool get _isAiLoading =>
      widget.isEnhancing || widget.isTranscribingBackground;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (_isAiLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AppRecordProcessingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasAi =
        oldWidget.isEnhancing || oldWidget.isTranscribingBackground;
    if (_isAiLoading && !wasAi) {
      _controller.repeat();
    } else if (!_isAiLoading && wasAi) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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

    if (_isAiLoading) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final angle = t * 2 * math.pi;
          final begin = Alignment(
            math.cos(angle),
            math.sin(angle),
          );
          final end = Alignment(
            -math.cos(angle),
            -math.sin(angle),
          );
          final pulse = (math.sin(t * 2 * math.pi) + 1) / 2;

          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: begin,
                end: end,
                colors: AppGradients.ai.colors,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.translate(
                          offset: Offset(0, -6 + (pulse * 12)),
                          child: Transform.scale(
                            scale: 0.9 + (pulse * 0.2),
                            child: Icon(
                              Icons.auto_awesome,
                              size: 56,
                              color: AppColors.highContrastWhite.withValues(
                                alpha: 0.75 + (pulse * 0.25),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10 + (pulse * 8),
                          right: 18 - (pulse * 6),
                          child: Opacity(
                            opacity: 0.35 + (pulse * 0.55),
                            child: Transform.rotate(
                              angle: pulse * 0.4,
                              child: const Icon(
                                Icons.auto_awesome,
                                size: 22,
                                color: AppColors.highContrastWhite,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 14 - (pulse * 8),
                          left: 14 + (pulse * 6),
                          child: Opacity(
                            opacity: 0.75 - (pulse * 0.4),
                            child: Transform.rotate(
                              angle: -pulse * 0.35,
                              child: const Icon(
                                Icons.auto_awesome_outlined,
                                size: 18,
                                color: AppColors.highContrastWhite,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppText(
                    message,
                    variant: AppTextVariant.body,
                    color: AppColors.highContrastWhite,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Container(
      color: AppColors.highContrastBlack.withValues(alpha: 0.54),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
