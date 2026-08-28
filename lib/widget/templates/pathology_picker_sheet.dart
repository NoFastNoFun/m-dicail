import 'package:flutter/material.dart';
import 'package:medicail/core/config/app_config.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/network/auth_token_storage.dart';
import 'package:medicail/features/pathology/domain/entities/mesh_descriptor.dart';
import 'package:medicail/features/pathology/domain/entities/pathology.dart';
import 'package:medicail/features/pathology/domain/entities/pathology_domain.dart';
import 'package:medicail/features/pathology/domain/repositories/pathology_repository.dart';
import 'package:medicail/features/pathology/domain/utils/pathology_labels.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_bottom_sheet.dart';
import 'package:medicail/widget/inputs/app_input.dart';

class PathologyPickerSheet extends StatefulWidget {
  const PathologyPickerSheet({
    super.key,
    required this.pathologies,
    required this.onSelected,
    this.selectedPathologyId,
    this.enablePubmedSearch = true,
  });

  final List<Pathology> pathologies;
  final ValueChanged<Pathology> onSelected;
  final String? selectedPathologyId;
  final bool enablePubmedSearch;

  static Future<Pathology?> show(
    BuildContext context, {
    required List<Pathology> pathologies,
    String? selectedPathologyId,
    bool enablePubmedSearch = true,
  }) {
    return showModalBottomSheet<Pathology>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.lgBorder,
      ),
      constraints: AppBottomSheet.sheetConstraints(context),
      builder: (context) {
        final height = MediaQuery.sizeOf(context).height * 0.75;
        return SizedBox(
          height: height,
          child: PathologyPickerSheet(
            pathologies: pathologies,
            selectedPathologyId: selectedPathologyId,
            enablePubmedSearch: enablePubmedSearch,
            onSelected: (pathology) => Navigator.of(context).pop(pathology),
          ),
        );
      },
    );
  }

  @override
  State<PathologyPickerSheet> createState() => _PathologyPickerSheetState();
}

class _PathologyPickerSheetState extends State<PathologyPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';
  List<MeshDescriptor> _pubmedResults = const [];
  bool _isSearchingPubmed = false;
  bool _canSearchPubmed = false;

  @override
  void initState() {
    super.initState();
    _loadOnlineState();
  }

  Future<void> _loadOnlineState() async {
    final token = await getIt<AuthTokenStorage>().readToken();
    if (!mounted) {
      return;
    }
    setState(() {
      _canSearchPubmed =
          widget.enablePubmedSearch && !AppConfig.isOfflineMode(token);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filtered = _filterLocal(widget.pathologies);
    final grouped = _groupByDomain(filtered);
    final showPubmedAction =
        _canSearchPubmed && _query.isNotEmpty && filtered.isEmpty;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(l10n.templatePickerTitle, variant: AppTextVariant.title),
          const SizedBox(height: AppSpacing.md),
          AppInput(
            variant: AppInputVariant.text,
            label: l10n.templatePickerSearch,
            controller: _searchController,
            validator: (_) => null,
            onChanged: (value) => setState(() => _query = value.trim()),
          ),
          const SizedBox(height: AppSpacing.md),
          if (showPubmedAction) ...[
            AppButton(
              label: l10n.pathologyPubmedSearchAction(_query),
              style: AppButtonStyle.secondary,
              layout: AppButtonLayout.textWithIcon,
              icon: Icons.search,
              onPressed: _isSearchingPubmed ? null : _searchPubmed,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Expanded(
            child: ListView(
              children: [
                if (_isSearchingPubmed)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_pubmedResults.isNotEmpty) ...[
                  AppText(
                    l10n.pathologyPubmedResultsSection,
                    variant: AppTextVariant.caption,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ..._pubmedResults.map(_buildPubmedTile),
                  const SizedBox(height: AppSpacing.md),
                ],
                for (final entry in grouped.entries) ...[
                  AppText(entry.key.labelFr(), variant: AppTextVariant.caption),
                  const SizedBox(height: AppSpacing.sm),
                  ...entry.value.map(_buildPathologyTile),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (!_isSearchingPubmed &&
                    filtered.isEmpty &&
                    _pubmedResults.isEmpty)
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

  List<Pathology> _filterLocal(List<Pathology> pathologies) {
    if (_query.isEmpty) {
      return pathologies;
    }
    final normalized = _query.toLowerCase();
    return pathologies.where((pathology) {
      if (pathology.name.toLowerCase().contains(normalized)) {
        return true;
      }
      final meshTerm = pathology.meshTerm;
      if (meshTerm != null && meshTerm.toLowerCase().contains(normalized)) {
        return true;
      }
      for (final alias in pathology.aliases) {
        if (alias.toLowerCase().contains(normalized)) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  Map<PathologyDomain, List<Pathology>> _groupByDomain(List<Pathology> items) {
    final grouped = <PathologyDomain, List<Pathology>>{};
    for (final pathology in items) {
      grouped.putIfAbsent(pathology.domain, () => []).add(pathology);
    }
    final domains = PathologyDomain.values
        .where((domain) => grouped.containsKey(domain))
        .toList();
    return {for (final domain in domains) domain: grouped[domain]!};
  }

  Future<void> _searchPubmed() async {
    if (_query.isEmpty) {
      return;
    }
    setState(() {
      _isSearchingPubmed = true;
      _pubmedResults = const [];
    });

    try {
      final results =
          await getIt<PathologyRepository>().searchPubmedMesh(_query);
      if (!mounted) {
        return;
      }
      setState(() {
        _pubmedResults = results;
        _isSearchingPubmed = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isSearchingPubmed = false);
    }
  }

  Future<void> _importPubmed(MeshDescriptor descriptor) async {
    final imported =
        await getIt<PathologyRepository>().importFromPubmed(descriptor);
    if (!mounted) {
      return;
    }
    widget.onSelected(imported);
  }

  Widget _buildPathologyTile(Pathology pathology) {
    final isSelected = pathology.id == widget.selectedPathologyId;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: AppText(pathology.name, variant: AppTextVariant.body),
      subtitle: AppText(pathology.sourceBadgeFr(), variant: AppTextVariant.caption),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: () => widget.onSelected(pathology),
    );
  }

  Widget _buildPubmedTile(MeshDescriptor descriptor) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: AppText(descriptor.term, variant: AppTextVariant.body),
      subtitle: AppText(
        descriptor.meshUi,
        variant: AppTextVariant.caption,
      ),
      trailing: const Icon(Icons.download_outlined),
      onTap: () => _importPubmed(descriptor),
    );
  }
}
