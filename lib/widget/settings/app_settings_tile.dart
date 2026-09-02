import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/widget/app_text.dart';

class AppSettingsTile extends StatelessWidget {
  const AppSettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.enabled = true,
    this.icon,
    this.iconColor,
    this.titleColor,
    this.trailing,
    this.child,
    this.onTap,
    this.showChevron = false,
  });

  final String title;
  final String? subtitle;
  final bool enabled;
  final IconData? icon;
  final Color? iconColor;
  final Color? titleColor;
  final Widget? trailing;
  final Widget? child;
  final VoidCallback? onTap;
  final bool showChevron;

  static const double _iconExtent = 40;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opacity = enabled ? 1.0 : 0.5;
    final resolvedIconColor = iconColor ?? theme.colorScheme.primary;
    final chevron = showChevron
        ? Icon(
            Icons.chevron_right,
            color: context.secondaryTextColor,
          )
        : null;

    Widget content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: child == null
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Container(
                  width: _iconExtent,
                  height: _iconExtent,
                  decoration: BoxDecoration(
                    color: resolvedIconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: resolvedIconColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      title,
                      variant: AppTextVariant.title,
                      color: titleColor,
                    ),
                    if (subtitle case final subtitle?)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: AppText(
                          subtitle,
                          variant: AppTextVariant.caption,
                          color: context.secondaryTextColor,
                        ),
                      ),
                  ],
                ),
              ),
              ?trailing,
              if (trailing == null && chevron != null) chevron,
            ],
          ),
          if (child case final child?) ...[
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ],
      ),
    );

    if (onTap != null) {
      content = InkWell(
        onTap: enabled ? onTap : null,
        child: content,
      );
    }

    return Opacity(opacity: opacity, child: content);
  }
}
