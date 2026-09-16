import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_state.dart';
import 'package:medicail/widget/app_text.dart';

/// Phased wait banner: Upload → Transcription → Polish with duration-based ETA.
class AppRecordPhasedWait extends StatefulWidget {
  const AppRecordPhasedWait({
    super.key,
    required this.phase,
    required this.recordingDuration,
  });

  final TranscriptionWaitPhase phase;
  final Duration recordingDuration;

  @override
  State<AppRecordPhasedWait> createState() => _AppRecordPhasedWaitState();
}

class _AppRecordPhasedWaitState extends State<AppRecordPhasedWait> {
  late DateTime _startedAt;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant AppRecordPhasedWait oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase != widget.phase) {
      _startedAt = DateTime.now();
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Duration get _eta {
    final seconds = widget.recordingDuration.inSeconds;
    final upload = Duration(seconds: math.max(2, (seconds * 0.05).round() + 2));
    final transcription = Duration(
      seconds: math.max(4, (seconds * 0.22).round() + 3),
    );
    final polish = const Duration(seconds: 18);
    return switch (widget.phase) {
      TranscriptionWaitPhase.upload => upload,
      TranscriptionWaitPhase.transcription => transcription,
      TranscriptionWaitPhase.polish => polish,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stages = [
      (
        TranscriptionWaitPhase.upload,
        l10n.recordPhaseUpload,
        Icons.cloud_upload_outlined,
      ),
      (
        TranscriptionWaitPhase.transcription,
        l10n.recordPhaseTranscription,
        Icons.graphic_eq,
      ),
      (
        TranscriptionWaitPhase.polish,
        l10n.recordPhasePolish,
        Icons.auto_awesome,
      ),
    ];
    final elapsed = DateTime.now().difference(_startedAt);
    final remaining = _eta - elapsed;
    final etaLabel = remaining.inSeconds > 0
        ? l10n.recordPhaseEtaSeconds(remaining.inSeconds)
        : l10n.recordPhaseEtaSoon;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppGradients.ai.colors),
        borderRadius: AppRadius.mdBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                for (var i = 0; i < stages.length; i++) ...[
                  if (i > 0)
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                        ),
                        color: AppColors.highContrastWhite.withValues(
                          alpha: _phaseIndex(widget.phase) >= i ? 0.9 : 0.25,
                        ),
                      ),
                    ),
                  _StageChip(
                    label: stages[i].$2,
                    icon: stages[i].$3,
                    active: widget.phase == stages[i].$1,
                    done: _phaseIndex(widget.phase) > i,
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              etaLabel,
              variant: AppTextVariant.caption,
              color: AppColors.highContrastWhite.withValues(alpha: 0.9),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static int _phaseIndex(TranscriptionWaitPhase phase) => switch (phase) {
    TranscriptionWaitPhase.upload => 0,
    TranscriptionWaitPhase.transcription => 1,
    TranscriptionWaitPhase.polish => 2,
  };
}

class _StageChip extends StatelessWidget {
  const _StageChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.done,
  });

  final String label;
  final IconData icon;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final alpha = active || done ? 1.0 : 0.45;
    return Column(
      children: [
        Icon(
          done ? Icons.check_circle : icon,
          size: 22,
          color: AppColors.highContrastWhite.withValues(alpha: alpha),
        ),
        const SizedBox(height: 4),
        AppText(
          label,
          variant: AppTextVariant.caption,
          color: AppColors.highContrastWhite.withValues(alpha: alpha),
        ),
      ],
    );
  }
}
