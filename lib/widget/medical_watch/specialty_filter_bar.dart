import 'package:flutter/material.dart';

import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/medical_watch/domain/enums/medical_watch_specialty.dart';

/// Barre horizontale de puces (Chips) pour filtrer les articles par spécialité.
class SpecialtyFilterBar extends StatelessWidget {
  const SpecialtyFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  /// Spécialité actuellement sélectionnée. `null` = "Tous".
  final MedicalWatchSpecialty? selected;

  /// Callback de sélection. `null` = "Tous".
  final ValueChanged<MedicalWatchSpecialty?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: l10n.medicalWatchFilterAll,
            isSelected: selected == null,
            theme: theme,
            onTap: () => onSelected(null),
          ),
          const SizedBox(width: AppSpacing.sm),
          ...MedicalWatchSpecialty.values.map(
            (specialty) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _FilterChip(
                label: specialty.label(l10n),
                isSelected: selected == specialty,
                theme: theme,
                onTap: () => onSelected(specialty),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isSelected ? theme.colorScheme.primary : theme.colorScheme.surface;
    final foregroundColor =
        isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;
    final borderColor =
        isSelected ? theme.colorScheme.primary : theme.dividerColor;

    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.pillBorder,
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(color: foregroundColor),
          ),
        ),
      ),
    );
  }
}
