import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/medical_watch/domain/entities/medical_watch_article.dart';
import 'package:medicail/features/medical_watch/domain/entities/medical_watch_specialty.dart';
import 'package:medicail/features/medical_watch/presentation/medical_watch_bloc.dart';
import 'package:medicail/features/medical_watch/presentation/medical_watch_event.dart';
import 'package:medicail/features/medical_watch/presentation/medical_watch_state.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_bottom_sheet.dart';
import 'package:medicail/widget/feedback/app_toast.dart';

class MedicalWatchPage extends StatelessWidget {
  const MedicalWatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MedicalWatchBloc>()..add(const MedicalWatchRequested()),
      child: const _MedicalWatchView(),
    );
  }
}

class _MedicalWatchView extends StatelessWidget {
  const _MedicalWatchView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MedicalWatchBloc, MedicalWatchState>(
      listener: (context, state) {
        if (state is MedicalWatchFailure) {
          AppToast.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final l10n = AppLocalizations.of(context);
        final articles = _articlesFromState(state);
        final isLoading = state is MedicalWatchLoading;

        return AppScaffold(
          title: l10n.medicalWatchTitle,
          actions: [
            IconButton(
              tooltip: l10n.medicalWatchRefresh,
              icon: Icon(Icons.refresh, color: context.colorScheme.onSurface),
              onPressed: isLoading
                  ? null
                  : () => context
                      .read<MedicalWatchBloc>()
                      .add(const MedicalWatchRefreshRequested()),
            ),
          ],
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SpecialtyFilter(selectedSpecialty: state.selectedSpecialty),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: AppText(
                      l10n.medicalWatchSectionTitle,
                      variant: AppTextVariant.title,
                    ),
                  ),
                  if (isLoading)
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: articles.isEmpty
                    ? _EmptyMedicalWatch(
                        isLoading: isLoading,
                        l10n: l10n,
                      )
                    : ListView.separated(
                        itemCount: articles.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          return _MedicalWatchArticleItem(
                            article: articles[index],
                            l10n: l10n,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<MedicalWatchArticle> _articlesFromState(MedicalWatchState state) {
    return switch (state) {
      MedicalWatchLoaded(:final articles) => articles,
      MedicalWatchLoading(:final previousArticles) => previousArticles,
      MedicalWatchFailure(:final articles) => articles,
      MedicalWatchInitial() => const [],
    };
  }
}

class _SpecialtyFilter extends StatelessWidget {
  const _SpecialtyFilter({required this.selectedSpecialty});

  final MedicalWatchSpecialty? selectedSpecialty;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _SpecialtyChip(
            label: l10n.medicalWatchFilterAll,
            selected: selectedSpecialty == null,
            onSelected: () => context
                .read<MedicalWatchBloc>()
                .add(const MedicalWatchSpecialtyChanged(null)),
          ),
          for (final specialty in MedicalWatchSpecialty.values) ...[
            const SizedBox(width: AppSpacing.sm),
            _SpecialtyChip(
              label: _specialtyLabel(l10n, specialty),
              selected: selectedSpecialty == specialty,
              onSelected: () => context
                  .read<MedicalWatchBloc>()
                  .add(MedicalWatchSpecialtyChanged(specialty)),
            ),
          ],
        ],
      ),
    );
  }
}

class _SpecialtyChip extends StatelessWidget {
  const _SpecialtyChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: AppText(label, variant: AppTextVariant.label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
    );
  }
}

class _EmptyMedicalWatch extends StatelessWidget {
  const _EmptyMedicalWatch({
    required this.isLoading,
    required this.l10n,
  });

  final bool isLoading;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppText(
        isLoading
            ? l10n.medicalWatchEmptyLoading
            : l10n.medicalWatchEmpty,
        variant: AppTextVariant.body,
        color: context.secondaryTextColor,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _MedicalWatchArticleItem extends StatelessWidget {
  const _MedicalWatchArticleItem({
    required this.article,
    required this.l10n,
  });

  final MedicalWatchArticle article;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metadata = [
      _specialtyLabel(l10n, article.specialty),
      if (article.publicationDate != null && article.publicationDate!.isNotEmpty)
        article.publicationDate!,
      if (article.authors.isNotEmpty) article.authors.take(3).join(', '),
    ].join(' - ');

    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdBorder,
        side: BorderSide(color: theme.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showArticleDetails(context, article, l10n),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(article.title, variant: AppTextVariant.title),
              const SizedBox(height: AppSpacing.sm),
              AppText(
                metadata,
                variant: AppTextVariant.caption,
                color: context.secondaryTextColor,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (article.abstractText.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                AppText(
                  article.abstractText,
                  variant: AppTextVariant.body,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (article.doi != null && article.doi!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Icon(
                      Icons.link,
                      size: 16,
                      color: context.secondaryTextColor,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: AppText(
                        article.doi!,
                        variant: AppTextVariant.caption,
                        color: context.secondaryTextColor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

void _showArticleDetails(
  BuildContext context,
  MedicalWatchArticle article,
  AppLocalizations l10n,
) {
  AppBottomSheet.show<void>(
    context,
    title: l10n.medicalWatchDetailsTitle,
    heightFraction: 0.86,
    child: _MedicalWatchArticleDetails(article: article, l10n: l10n),
  );
}

class _MedicalWatchArticleDetails extends StatelessWidget {
  const _MedicalWatchArticleDetails({
    required this.article,
    required this.l10n,
  });

  final MedicalWatchArticle article;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(article.title, variant: AppTextVariant.title),
        const SizedBox(height: AppSpacing.md),
        _ArticleDetailRow(
          label: l10n.medicalWatchSpecialtyLabel,
          value: _specialtyLabel(l10n, article.specialty),
        ),
        if (article.publicationDate != null &&
            article.publicationDate!.isNotEmpty)
          _ArticleDetailRow(
            label: l10n.medicalWatchPublicationDate,
            value: article.publicationDate!,
          ),
        if (article.authors.isNotEmpty)
          _ArticleDetailRow(
            label: l10n.medicalWatchAuthors,
            value: article.authors.join(', '),
          ),
        if (article.doi != null && article.doi!.isNotEmpty)
          _ArticleDetailRow(label: l10n.medicalWatchDoi, value: article.doi!),
        _ArticleDetailRow(label: l10n.medicalWatchPmid, value: article.pmid),
        _ArticleDetailRow(
          label: l10n.medicalWatchSearchQuery,
          value: article.searchQuery,
        ),
        if (article.abstractText.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          AppText(l10n.medicalWatchAbstract, variant: AppTextVariant.title),
          const SizedBox(height: AppSpacing.sm),
          AppText(article.abstractText, variant: AppTextVariant.body),
        ],
      ],
    );
  }
}

class _ArticleDetailRow extends StatelessWidget {
  const _ArticleDetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            label,
            variant: AppTextVariant.caption,
            color: context.secondaryTextColor,
          ),
          const SizedBox(height: AppSpacing.xs),
          AppText(value, variant: AppTextVariant.body),
        ],
      ),
    );
  }
}

String _specialtyLabel(
  AppLocalizations l10n,
  MedicalWatchSpecialty specialty,
) {
  return switch (specialty) {
    MedicalWatchSpecialty.rehabilitation =>
      l10n.medicalWatchSpecialtyRehabilitation,
    MedicalWatchSpecialty.musculoskeletal =>
      l10n.medicalWatchSpecialtyMusculoskeletal,
    MedicalWatchSpecialty.exerciseTherapy =>
      l10n.medicalWatchSpecialtyExerciseTherapy,
    MedicalWatchSpecialty.manualTherapy =>
      l10n.medicalWatchSpecialtyManualTherapy,
  };
}
