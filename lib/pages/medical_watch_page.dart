import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/features/medical_watch/domain/entities/medical_watch_article.dart';
import 'package:medicail/features/medical_watch/domain/entities/medical_watch_specialty.dart';
import 'package:medicail/features/medical_watch/presentation/medical_watch_bloc.dart';
import 'package:medicail/features/medical_watch/presentation/medical_watch_event.dart';
import 'package:medicail/features/medical_watch/presentation/medical_watch_state.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';
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
        final articles = _articlesFromState(state);
        final isLoading = state is MedicalWatchLoading;

        return AppScaffold(
          title: 'Veille médicale',
          actions: [
            IconButton(
              tooltip: 'Actualiser',
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
                  const Expanded(
                    child: AppText(
                      'Articles PubMed',
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
                    ? _EmptyMedicalWatch(isLoading: isLoading)
                    : ListView.separated(
                        itemCount: articles.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          return _MedicalWatchArticleItem(
                            article: articles[index],
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _SpecialtyChip(
            label: 'Toutes',
            selected: selectedSpecialty == null,
            onSelected: () => context
                .read<MedicalWatchBloc>()
                .add(const MedicalWatchSpecialtyChanged(null)),
          ),
          for (final specialty in MedicalWatchSpecialty.values) ...[
            const SizedBox(width: AppSpacing.sm),
            _SpecialtyChip(
              label: _specialtyLabel(specialty),
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
  const _EmptyMedicalWatch({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppText(
        isLoading
            ? 'Chargement des articles...'
            : 'Aucun article de veille disponible.',
        variant: AppTextVariant.body,
        color: context.secondaryTextColor,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _MedicalWatchArticleItem extends StatelessWidget {
  const _MedicalWatchArticleItem({required this.article});

  final MedicalWatchArticle article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metadata = [
      _specialtyLabel(article.specialty),
      if (article.publicationDate != null && article.publicationDate!.isNotEmpty)
        article.publicationDate!,
      if (article.authors.isNotEmpty) article.authors.take(3).join(', '),
    ].join(' - ');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor),
        borderRadius: AppRadius.mdBorder,
      ),
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
    );
  }
}

String _specialtyLabel(MedicalWatchSpecialty specialty) {
  return switch (specialty) {
    MedicalWatchSpecialty.rehabilitation => 'Rééducation',
    MedicalWatchSpecialty.musculoskeletal => 'Musculosquelettique',
    MedicalWatchSpecialty.exerciseTherapy => 'Thérapie par exercice',
    MedicalWatchSpecialty.manualTherapy => 'Thérapie manuelle',
  };
}
