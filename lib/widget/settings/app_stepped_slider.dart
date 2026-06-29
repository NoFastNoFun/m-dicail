import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/widget/app_text.dart';

class AppSteppedSlider extends StatelessWidget {
  const AppSteppedSlider({
    super.key,
    required this.steps,
    required this.value,
    required this.onChanged,
    this.minLabel,
    this.maxLabel,
  });

  final List<String> steps;
  final int value;
  final ValueChanged<int> onChanged;
  final String? minLabel;
  final String? maxLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedValue = value.clamp(0, steps.length - 1);
    final currentLabel = steps[clampedValue];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          currentLabel,
          variant: AppTextVariant.label,
          textAlign: TextAlign.center,
        ),
        Slider(
          value: clampedValue.toDouble(),
          min: 0,
          max: (steps.length - 1).toDouble(),
          divisions: steps.length - 1,
          label: currentLabel,
          activeColor: theme.colorScheme.primary,
          inactiveColor: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          onChanged: (next) => onChanged(next.round()),
        ),
        if (minLabel != null || maxLabel != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (minLabel != null)
                  AppText(minLabel!, variant: AppTextVariant.caption)
                else
                  const SizedBox.shrink(),
                if (maxLabel != null)
                  AppText(maxLabel!, variant: AppTextVariant.caption)
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
      ],
    );
  }
}
