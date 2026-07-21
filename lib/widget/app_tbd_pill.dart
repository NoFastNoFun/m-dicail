import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/widget/app_text.dart';

class AppTbdPill extends StatelessWidget {
  const AppTbdPill({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.smBorder,
        border: Border.all(color: theme.dividerColor),
      ),
      child: AppText(
        label,
        variant: AppTextVariant.caption,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }
}
