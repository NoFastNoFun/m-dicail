import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/pathology/domain/entities/pathology.dart';
import 'package:medicail/features/pathology/domain/utils/pathology_suggestion_matcher.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_bottom_sheet.dart';
import 'package:medicail/widget/templates/pathology_picker_sheet.dart';

class PathologyMultiSuggestionSheet extends StatefulWidget {
  const PathologyMultiSuggestionSheet({
    super.key,
    required this.suggestions,
    required this.pathologies,
  });

  final List<PathologySuggestion> suggestions;
  final List<Pathology> pathologies;

  static Future<List<Pathology>?> show(
    BuildContext context, {
    required List<PathologySuggestion> suggestions,
    required List<Pathology> pathologies,
  }) {
    return showModalBottomSheet<List<Pathology>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.lgBorder,
      ),
      constraints: AppBottomSheet.sheetConstraints(context),
      builder: (context) => PathologyMultiSuggestionSheet(
        suggestions: suggestions,
        pathologies: pathologies,
      ),
    );
  }

  @override
  State<PathologyMultiSuggestionSheet> createState() =>
      _PathologyMultiSuggestionSheetState();
}

class _PathologyMultiSuggestionSheetState
    extends State<PathologyMultiSuggestionSheet> {
  late final Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = {
      for (final suggestion in widget.suggestions) suggestion.pathology.id,
    };
  }

  List<Pathology> get _selectedPathologies {
    return widget.suggestions
        .where((s) => _selectedIds.contains(s.pathology.id))
        .map((s) => s.pathology)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = _selectedPathologies;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            l10n.pathologyMultiSuggestionTitle,
            variant: AppTextVariant.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            l10n.pathologyMultiSuggestionDesc,
            variant: AppTextVariant.body,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.suggestions.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, index) {
                final suggestion = widget.suggestions[index];
                final pathology = suggestion.pathology;
                final checked = _selectedIds.contains(pathology.id);
                return CheckboxListTile(
                  value: checked,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: AppText(
                    pathology.name,
                    variant: AppTextVariant.label,
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedIds.add(pathology.id);
                      } else {
                        _selectedIds.remove(pathology.id);
                      }
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: l10n.pathologyMultiSuggestionApply,
            enabled: selected.isNotEmpty,
            onPressed: selected.isEmpty
                ? null
                : () => Navigator.of(context).pop(selected),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l10n.pathologySuggestionChooseOther,
            style: AppButtonStyle.secondary,
            onPressed: () async {
              final pathology = await PathologyPickerSheet.show(
                context,
                pathologies: widget.pathologies,
              );
              if (!context.mounted || pathology == null) {
                return;
              }
              Navigator.of(context).pop([pathology]);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l10n.pathologySuggestionSkip,
            style: AppButtonStyle.tertiary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
