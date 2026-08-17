import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/patient_creation_sheet.dart';

class HomeHeroActions extends StatelessWidget {
  const HomeHeroActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: _HeroActionCard(
            icon: Icons.mic,
            label: l10n.homeQuickRecord,
            onTap: () => context.goRecord(),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _HeroActionCard(
            icon: Icons.person_add_outlined,
            label: l10n.homeNewPatient,
            onTap: () => PatientCreationSheet.show(context),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _HeroActionCard(
            icon: Icons.calendar_today_outlined,
            label: l10n.homeViewAgenda,
            onTap: () => context.goAppointments(),
          ),
        ),
      ],
    );
  }
}

class _HeroActionCard extends StatelessWidget {
  const _HeroActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdBorder,
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdBorder,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppText(
                label,
                variant: AppTextVariant.caption,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
