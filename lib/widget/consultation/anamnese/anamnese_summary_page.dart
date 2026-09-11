import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/layout/app_content_constraint.dart';
import 'package:medicail/features/patient/domain/entities/anamnese.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/consultation/anamnese/anamnese_summary_content.dart';

/// Opens the read-only history without entering the editing workflow.
Future<void> showAnamneseSummary(
  BuildContext context, {
  required Patient patient,
}) => showDialog<void>(
  context: context,
  useRootNavigator: true,
  barrierDismissible: false,
  builder: (_) => Dialog.fullscreen(
    child: SafeArea(child: AnamneseSummaryPage(patient: patient)),
  ),
);

class AnamneseSummaryPage extends StatefulWidget {
  const AnamneseSummaryPage({super.key, required this.patient});

  final Patient patient;

  @override
  State<AnamneseSummaryPage> createState() => _AnamneseSummaryPageState();
}

class _AnamneseSummaryPageState extends State<AnamneseSummaryPage> {
  bool _showDetails = false;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleDetails() {
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    setState(() => _showDetails = !_showDetails);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sections = buildAnamneseSummary(
      widget.patient.metadata.anamnese,
      l10n,
    ).where((section) => _showDetails || section.isFilled).toList();

    return AppContentConstraint(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppText(
                    l10n.anamneseSummaryTitle,
                    variant: AppTextVariant.title,
                  ),
                ),
                IconButton(
                  tooltip: l10n.anamneseSummaryClose,
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                AppText(
                  widget.patient.displayName,
                  variant: AppTextVariant.label,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppText(
                  _showDetails
                      ? l10n.anamneseSummaryDetailedHint
                      : l10n.anamneseSummaryCompactHint,
                  variant: AppTextVariant.caption,
                  color: context.secondaryTextColor,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  onPressed: _toggleDetails,
                  style: AppButtonStyle.secondary,
                  label: _showDetails
                      ? l10n.anamneseSummaryShowCompact
                      : l10n.anamneseSummaryShowDetails,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (sections.isEmpty)
                  AppText(
                    l10n.anamneseCardEmpty,
                    variant: AppTextVariant.body,
                    color: context.secondaryTextColor,
                  ),
                for (final section in sections)
                  _SummarySection(section: section, showDetails: _showDetails),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: AppButton(
              onPressed: () => Navigator.of(context).pop(),
              label: l10n.anamneseSummaryClose,
              style: AppButtonStyle.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.section, required this.showDetails});

  final AnamneseSummarySection section;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    final fields = section.fields.where(
      (field) => showDetails || field.isFilled,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadius.mdBorder,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(section.title, variant: AppTextVariant.title),
              const SizedBox(height: AppSpacing.sm),
              for (final field in fields)
                _SummaryField(field: field, showDetails: showDetails),
              for (final group in section.groups)
                if (showDetails || group.any((field) => field.isFilled))
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.smBorder,
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final field in group)
                              if (showDetails || field.isFilled)
                                _SummaryField(
                                  field: field,
                                  showDetails: showDetails,
                                ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryField extends StatelessWidget {
  const _SummaryField({required this.field, required this.showDetails});

  final AnamneseSummaryField field;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: AppText(
        l10n.anamneseSummaryLabelValue(
          field.label,
          field.isFilled ? field.value!.trim() : l10n.anamneseSummaryNotFilled,
        ),
        variant: AppTextVariant.body,
        color: field.isFilled ? null : context.secondaryTextColor,
        maxLines: showDetails ? null : 2,
        overflow: showDetails ? null : TextOverflow.ellipsis,
      ),
    );
  }
}
