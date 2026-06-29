import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/widget/app_text.dart';

class AppSettingsTile extends StatelessWidget {
  const AppSettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.enabled = true,
    this.trailing,
    this.child,
  });

  final String title;
  final String? subtitle;
  final bool enabled;
  final Widget? trailing;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opacity = enabled ? 1.0 : 0.5;

    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
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
                      AppText(title, variant: AppTextVariant.title),
                      if (subtitle case final subtitle?)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: AppText(
                            subtitle,
                            variant: AppTextVariant.caption,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
            ...? (child == null
                ? null
                : [
                    const SizedBox(height: AppSpacing.md),
                    child!,
                  ]),
          ],
        ),
      ),
    );
  }
}
