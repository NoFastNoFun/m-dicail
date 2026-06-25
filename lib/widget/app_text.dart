import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_typography.dart';

enum AppTextVariant { display, headline, title, body, label, caption }

class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    super.key,
    required this.variant,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String data;
  final AppTextVariant variant;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final metrics = switch (variant) {
      AppTextVariant.display => AppTypography.display,
      AppTextVariant.headline => AppTypography.headline,
      AppTextVariant.title => AppTypography.title,
      AppTextVariant.body => AppTypography.body,
      AppTextVariant.label => AppTypography.label,
      AppTextVariant.caption => AppTypography.caption,
    };

    final themeStyle = switch (variant) {
      AppTextVariant.display => theme.textTheme.displayLarge,
      AppTextVariant.headline => theme.textTheme.headlineMedium,
      AppTextVariant.title => theme.textTheme.titleMedium,
      AppTextVariant.body =>
        theme.textTheme.bodyLarge ?? theme.textTheme.bodyMedium,
      AppTextVariant.label => theme.textTheme.labelLarge,
      AppTextVariant.caption => theme.textTheme.bodySmall,
    };

    final defaultColor = variant == AppTextVariant.caption
        ? theme.colorScheme.onSurface.withValues(alpha: 0.65)
        : theme.colorScheme.onSurface;

    final style = metrics.copyWith(
      color: color ?? themeStyle?.color ?? defaultColor,
    );

    return Text(
      data,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
