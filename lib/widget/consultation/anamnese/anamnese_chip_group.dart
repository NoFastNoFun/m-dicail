import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/widget/app_text.dart';

class AnamneseChipOption {
  const AnamneseChipOption({required this.value, required this.label});

  final String value;
  final String label;
}

/// Single- or multi-select chip group used across anamnèse pages.
class AnamneseChipGroup extends StatelessWidget {
  const AnamneseChipGroup({
    super.key,
    this.label,
    required this.options,
    this.selected,
    this.selectedValues = const {},
    this.multi = false,
    required this.onChanged,
  });

  final String? label;
  final List<AnamneseChipOption> options;
  final String? selected;
  final Set<String> selectedValues;
  final bool multi;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          AppText(label!, variant: AppTextVariant.label),
          const SizedBox(height: AppSpacing.sm),
        ],
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final option in options)
              FilterChip(
                label: Text(option.label),
                selected: multi
                    ? selectedValues.contains(option.value)
                    : selected == option.value,
                onSelected: (_) {
                  if (multi) {
                    final next = Set<String>.from(selectedValues);
                    if (next.contains(option.value)) {
                      next.remove(option.value);
                    } else {
                      next.add(option.value);
                    }
                    onChanged(next);
                  } else {
                    onChanged(selected == option.value ? null : option.value);
                  }
                },
              ),
          ],
        ),
      ],
    );
  }
}
