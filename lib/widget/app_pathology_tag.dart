import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/widget/app_text.dart';

class AppPathologyTag extends StatelessWidget {
  const AppPathologyTag({
    super.key,
    required this.label,
    this.onTap,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final background = colorScheme.primary.withValues(alpha: 0.12);
    final foreground = colorScheme.primary;

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.local_offer_outlined,
          size: compact ? 14 : 16,
          color: foreground,
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: AppText(
            label,
            variant: compact ? AppTextVariant.caption : AppTextVariant.label,
            color: foreground,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onTap != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Icon(
            Icons.expand_more,
            size: compact ? 14 : 16,
            color: foreground,
          ),
        ],
      ],
    );

    final padding = EdgeInsets.symmetric(
      horizontal: compact ? AppSpacing.sm : AppSpacing.md,
      vertical: compact ? AppSpacing.xs : AppSpacing.sm,
    );

    if (onTap == null) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.pillBorder,
          border: Border.all(color: foreground.withValues(alpha: 0.25)),
        ),
        child: child,
      );
    }

    return Material(
      color: background,
      borderRadius: AppRadius.pillBorder,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pillBorder,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: AppRadius.pillBorder,
            border: Border.all(color: foreground.withValues(alpha: 0.25)),
          ),
          child: child,
        ),
      ),
    );
  }
}
