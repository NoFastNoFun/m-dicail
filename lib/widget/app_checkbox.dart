import 'package:flutter/material.dart';
import 'package:medicail/widget/app_text.dart';

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      activeColor: colorScheme.primary,
      checkColor: colorScheme.onPrimary,
      title: AppText(label, variant: AppTextVariant.body),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
}
