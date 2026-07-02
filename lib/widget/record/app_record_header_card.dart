import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/record/app_record_toggle_button.dart';
import 'package:showcaseview/showcaseview.dart';

class AppRecordHeaderCard extends StatelessWidget {
  const AppRecordHeaderCard({
    super.key,
    required this.dateLabel,
    this.sessionTitle,
    required this.elapsedLabel,
    required this.isRecording,
    required this.isInitializing,
    required this.canStart,
    required this.canStop,
    required this.onBack,
    required this.onToggleRecording,
    required this.menuItems,
    this.menuKey,
    this.menuButtonKey,
    this.menuShowcaseTitle,
    this.menuShowcaseDescription,
    this.onMenuShowcaseTargetClick,
  });

  final String dateLabel;
  final String? sessionTitle;
  final String elapsedLabel;
  final bool isRecording;
  final bool isInitializing;
  final bool canStart;
  final bool canStop;
  final VoidCallback onBack;
  final VoidCallback onToggleRecording;
  final List<AppRecordMenuItem> menuItems;
  final GlobalKey? menuKey;
  final GlobalKey<PopupMenuButtonState<int>>? menuButtonKey;
  final String? menuShowcaseTitle;
  final String? menuShowcaseDescription;
  final VoidCallback? onMenuShowcaseTargetClick;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final controlSurface = colorScheme.surface.withValues(alpha: 0.9);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.mdBorder,
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
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _SideControlButton(
                icon: Icons.logout,
                backgroundColor: controlSurface,
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
              const SizedBox(width: AppSpacing.md),
              if (menuKey != null)
                Showcase(
                  key: menuKey!,
                  title: menuShowcaseTitle,
                  description: menuShowcaseDescription,
                  disposeOnTap: false,
                  disableBarrierInteraction: true,
                  onTargetClick: onMenuShowcaseTargetClick,
                  child: _RecordMenuButton(
                    menuButtonKey: menuButtonKey,
                    backgroundColor: controlSurface,
                    items: menuItems,
                  ),
                )
              else
                _RecordMenuButton(
                  menuButtonKey: menuButtonKey,
                  backgroundColor: controlSurface,
                  items: menuItems,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class AppRecordMenuItem {
  const AppRecordMenuItem({
    required this.label,
    required this.onSelected,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onSelected;
  final bool enabled;
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
    required this.onPressed,
  });

  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: AppRadius.smBorder,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.smBorder,
        child: SizedBox(
          width: AppSpacing.minTouchTarget,
          height: AppSpacing.minTouchTarget,
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}

class _RecordMenuButton extends StatelessWidget {
  const _RecordMenuButton({
    required this.backgroundColor,
    required this.items,
    this.menuButtonKey,
  });

  final Color backgroundColor;
  final List<AppRecordMenuItem> items;
  final GlobalKey<PopupMenuButtonState<int>>? menuButtonKey;

  @override
  Widget build(BuildContext context) {
    final enabledItems = items.where((item) => item.enabled).toList();

    return Material(
      color: backgroundColor,
      borderRadius: AppRadius.smBorder,
      clipBehavior: Clip.antiAlias,
      child: PopupMenuButton<int>(
        key: menuButtonKey,
        enabled: enabledItems.isNotEmpty,
        icon: const Icon(Icons.more_vert, size: 20),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: AppSpacing.minTouchTarget,
          minHeight: AppSpacing.minTouchTarget,
        ),
        itemBuilder: (context) {
          return [
            for (var i = 0; i < items.length; i++)
              PopupMenuItem<int>(
                value: i,
                enabled: items[i].enabled,
                child: AppText(
                  items[i].label,
                  variant: AppTextVariant.body,
                ),
              ),
          ];
        },
        onSelected: (index) => items[index].onSelected(),
      ),
    );
  }
}
