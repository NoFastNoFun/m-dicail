import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/widget/app_pathology_tag.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/record/app_record_toggle_button.dart';

class AppRecordHeaderCard extends StatelessWidget {
  const AppRecordHeaderCard({
    super.key,
    required this.dateLabel,
    this.sessionTitle,
    this.pathologyTagName,
    this.pathologyPlaceholder,
    this.onPathologyTap,
    required this.elapsedLabel,
    required this.isRecording,
    required this.isInitializing,
    required this.canStart,
    required this.canStop,
    required this.onBack,
    required this.onToggleRecording,
    this.cardBorderRadius = AppRadius.mdBorder,
    this.controlBorderRadius = AppRadius.pillBorder,
  });

  final String dateLabel;
  final String? sessionTitle;
  final String? pathologyTagName;
  final String? pathologyPlaceholder;
  final VoidCallback? onPathologyTap;
  final String elapsedLabel;
  final bool isRecording;
  final bool isInitializing;
  final bool canStart;
  final bool canStop;
  final VoidCallback onBack;
  final VoidCallback onToggleRecording;
  final BorderRadius cardBorderRadius;
  final BorderRadius controlBorderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final controlSurface = colorScheme.surface.withValues(alpha: 0.9);
    final hasPathologyTag =
        pathologyTagName != null && pathologyTagName!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: cardBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      dateLabel,
                      variant: AppTextVariant.caption,
                      color: context.secondaryTextColor,
                    ),
                    if (sessionTitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      AppText(
                        sessionTitle!,
                        variant: AppTextVariant.headline,
                      ),
                    ],
                  ],
                ),
              ),
              if (isRecording) ...[
                const SizedBox(width: AppSpacing.md),
                _RecordingTimer(label: elapsedLabel),
              ],
            ],
          ),
          if (hasPathologyTag || pathologyPlaceholder != null) ...[
            const SizedBox(height: AppSpacing.md),
            if (hasPathologyTag)
              Align(
                alignment: Alignment.centerLeft,
                child: AppPathologyTag(
                  label: pathologyTagName!,
                  onTap: onPathologyTap,
                ),
              )
            else
              _PathologyPlaceholder(
                label: pathologyPlaceholder!,
                onTap: onPathologyTap,
              ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _SideControlButton(
                icon: Icons.close,
                backgroundColor: controlSurface,
                borderRadius: controlBorderRadius,
                onPressed: onBack,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppRecordToggleButton(
                  isRecording: isRecording,
                  isLoading: isInitializing,
                  enabled: canStart || canStop,
                  onPressed: onToggleRecording,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PathologyPlaceholder extends StatelessWidget {
  const _PathologyPlaceholder({
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isInteractive = onTap != null;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.medical_information_outlined,
          size: 18,
          color: isInteractive ? colorScheme.primary : context.secondaryTextColor,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: AppText(
            label,
            variant: AppTextVariant.label,
            color: isInteractive ? colorScheme.primary : context.secondaryTextColor,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isInteractive) ...[
          const SizedBox(width: AppSpacing.xs),
          Icon(
            Icons.expand_more,
            size: 18,
            color: colorScheme.primary,
          ),
        ],
      ],
    );

    if (!isInteractive) {
      return content;
    }

    return Material(
      color: colorScheme.primary.withValues(alpha: 0.08),
      borderRadius: AppRadius.smBorder,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smBorder,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: content,
        ),
      ),
    );
  }
}

class _RecordingTimer extends StatelessWidget {
  const _RecordingTimer({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.error,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        AppText(
          label,
          variant: AppTextVariant.label,
        ),
      ],
    );
  }
}

class _SideControlButton extends StatelessWidget {
  const _SideControlButton({
    required this.icon,
    required this.backgroundColor,
    required this.borderRadius,
    required this.onPressed,
  });

  final IconData icon;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius,
        child: SizedBox(
          width: AppSpacing.minTouchTarget,
          height: AppSpacing.minTouchTarget,
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}
