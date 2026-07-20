import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/features/note_template/domain/entities/note_template_source.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/inputs/app_input.dart';

class TemplatePickerSheet extends StatefulWidget {
  const TemplatePickerSheet({
    super.key,
    required this.templates,
    required this.onSelected,
    this.selectedTemplateId,
  });

  final List<NoteTemplate> templates;
  final ValueChanged<NoteTemplate> onSelected;
  final String? selectedTemplateId;

  static Future<NoteTemplate?> show(
    BuildContext context, {
    required List<NoteTemplate> templates,
    String? selectedTemplateId,
  }) {
    return showModalBottomSheet<NoteTemplate>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => TemplatePickerSheet(
        templates: templates,
        selectedTemplateId: selectedTemplateId,
        onSelected: (template) => Navigator.of(context).pop(template),
      ),
    );
  }

  @override
  State<TemplatePickerSheet> createState() => _TemplatePickerSheetState();
}

class _TemplatePickerSheetState extends State<TemplatePickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final builtIn = widget.templates
        .where((template) => template.source == NoteTemplateSource.builtIn)
        .where(_matchesQuery)
        .toList();
    final variants = widget.templates
        .where((template) => template.source == NoteTemplateSource.userVariant)
        .where(_matchesQuery)
        .toList();

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
          AppText(l10n.templatePickerTitle, variant: AppTextVariant.title),
          const SizedBox(height: AppSpacing.md),
          AppInput(
            variant: AppInputVariant.text,
            label: l10n.templatePickerSearch,
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value.trim()),
          ),
          const SizedBox(height: AppSpacing.md),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                if (builtIn.isNotEmpty) ...[
                  AppText(
                    l10n.templatesBuiltInSection,
                    variant: AppTextVariant.caption,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...builtIn.map(_buildTile),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (variants.isNotEmpty) ...[
                  AppText(
                    l10n.templatesUserSection,
                    variant: AppTextVariant.caption,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...variants.map(_buildTile),
                ],
                if (builtIn.isEmpty && variants.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: AppText(
                      l10n.templatePickerEmpty,
                      variant: AppTextVariant.body,
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _matchesQuery(NoteTemplate template) {
    if (_query.isEmpty) {
      return true;
    }
    return template.name.toLowerCase().contains(_query.toLowerCase());
  }

  Widget _buildTile(NoteTemplate template) {
    final isSelected = template.id == widget.selectedTemplateId;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: AppText(template.name, variant: AppTextVariant.body),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: () => widget.onSelected(template),
    );
  }
}
