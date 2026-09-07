import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_spacing.dart';

class AppColorSwatchPicker extends StatelessWidget {
  const AppColorSwatchPicker({
    super.key,
    required this.colors,
    required this.selected,
    required this.onChanged,
  });

  final List<Color> colors;
  final Color selected;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedArgb = selected.toARGB32();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = color.toARGB32() == selectedArgb;

          return Semantics(
            button: true,
            selected: isSelected,
            child: InkWell(
              onTap: () => onChanged(color),
              customBorder: const CircleBorder(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.onSurface
                        : theme.dividerColor,
                    width: isSelected ? 2.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.16),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 18,
                        color: color.computeLuminance() > 0.55
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.surface,
                      )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
