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
    final baseStyle = switch (variant) {
      AppTextVariant.display => AppTypography.display,
      AppTextVariant.headline => AppTypography.headline,
      AppTextVariant.title => AppTypography.title,
      AppTextVariant.body => AppTypography.body,
      AppTextVariant.label => AppTypography.label,
      AppTextVariant.caption => AppTypography.caption,
    };

    return Text(
      data,
      style: color != null ? baseStyle.copyWith(color: color) : baseStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
