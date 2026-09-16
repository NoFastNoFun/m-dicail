import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/error/failure.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/features/search/data/global_search_service.dart';
import 'package:medicail/features/search/domain/global_search_result.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/widget/inputs/app_input.dart';
import 'package:medicail/widget/layout/app_empty_state.dart';

class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  bool _loading = false;
  GlobalSearchResults _results = const GlobalSearchResults();
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onQueryChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onQueryChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _runSearch);
  }

  Future<void> _runSearch() async {
    final query = _controller.text.trim();
    if (query == _lastQuery && !_loading) {
      if (query.isEmpty) {
        setState(() => _results = const GlobalSearchResults());
      }
      return;
    }
    _lastQuery = query;
    if (query.isEmpty) {
      setState(() {
        _loading = false;
        _results = const GlobalSearchResults();
      });
      return;
    }

    setState(() => _loading = true);
    try {
      final results = await getIt<GlobalSearchService>().search(query);
      if (!mounted || _controller.text.trim() != query) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      AppToast.showError(context, Failure.fromException(error).message);
    }
  }

  void _openPatient(String patientId) {
    context.pushPatientDetail(patientId);
  }

  void _openSession(GlobalSearchSessionHit hit) {
    final patientId = hit.session.patientId;
    if (patientId == null || patientId.isEmpty) {
      return;
    }
    context.push(
      Uri(
        path: '/patients/$patientId',
        queryParameters: {'sessionId': hit.session.id},
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = _controller.text.trim();
    final showHint = query.isEmpty && !_loading;
    final showEmpty =
        query.isNotEmpty && !_loading && _results.isEmpty;

    return AppScaffold(
      title: l10n.globalSearchTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppInput(
            variant: AppInputVariant.text,
            label: l10n.globalSearchPlaceholder,
            controller: _controller,
            focusNode: _focusNode,
            prefixIcon: Icons.search,
            textInputAction: TextInputAction.search,
            onFieldSubmitted: (_) => _runSearch(),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_loading)
            const LinearProgressIndicator(minHeight: 2)
          else
            const SizedBox(height: 2),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: showHint
                ? AppEmptyState(
                    icon: Icons.travel_explore_outlined,
                    message: l10n.globalSearchHint,
                  )
                : showEmpty
                ? AppEmptyState(
                    icon: Icons.search_off_outlined,
                    message: l10n.globalSearchEmpty,
                  )
                : ListView(
                    children: [
                      if (_results.patients.isNotEmpty) ...[
                        AppText(
                          l10n.globalSearchPatientsSection,
                          variant: AppTextVariant.title,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        for (final hit in _results.patients)
                          _PatientResultTile(
                            hit: hit,
                            onTap: () => _openPatient(hit.patient.id),
                          ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      if (_results.sessions.isNotEmpty) ...[
                        AppText(
                          l10n.globalSearchSessionsSection,
                          variant: AppTextVariant.title,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        for (final hit in _results.sessions)
                          _SessionResultTile(
                            hit: hit,
                            untitledLabel: l10n.globalSearchSessionUntitled,
                            onTap: hit.session.patientId == null
                                ? null
                                : () => _openSession(hit),
                          ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _PatientResultTile extends StatelessWidget {
  const _PatientResultTile({required this.hit, required this.onTap});

  final GlobalSearchPatientHit hit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final patient = hit.patient;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdBorder,
          side: BorderSide(color: theme.dividerColor),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mdBorder,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.person_outline, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        patient.displayName,
                        variant: AppTextVariant.label,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      AppText(
                        'MRN: ${patient.mrn}',
                        variant: AppTextVariant.caption,
                        color: context.secondaryTextColor,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: context.secondaryTextColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionResultTile extends StatelessWidget {
  const _SessionResultTile({
    required this.hit,
    required this.untitledLabel,
    this.onTap,
  });

  final GlobalSearchSessionHit hit;
  final String untitledLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = hit.session;
    final title = hit.patientName?.trim().isNotEmpty == true
        ? hit.patientName!
        : (session.pathologyNames.isNotEmpty
            ? session.pathologyNames.join(', ')
            : untitledLabel);
    final dateStr =
        DateFormat('dd/MM/yyyy HH:mm').format(session.startedAt.toLocal());

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdBorder,
          side: BorderSide(color: theme.dividerColor),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mdBorder,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.mic_none_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(title, variant: AppTextVariant.label),
                      const SizedBox(height: AppSpacing.xs),
                      AppText(
                        dateStr,
                        variant: AppTextVariant.caption,
                        color: context.secondaryTextColor,
                      ),
                      if (hit.snippet != null && hit.snippet!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        AppText(
                          hit.snippet!,
                          variant: AppTextVariant.caption,
                          color: context.secondaryTextColor,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right,
                    color: context.secondaryTextColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
