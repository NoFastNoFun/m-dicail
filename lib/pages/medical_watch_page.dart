import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/layout/app_breakpoints.dart';
import 'package:medicail/core/layout/main_shell_chrome.dart';
import 'package:medicail/features/medical_watch/presentation/medical_watch_bloc.dart';
import 'package:medicail/features/medical_watch/presentation/medical_watch_event.dart';
import 'package:medicail/features/medical_watch/presentation/medical_watch_state.dart';
import 'package:medicail/features/medical_watch/domain/entities/medical_watch_article.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/widget/inputs/app_input.dart';
import 'package:medicail/widget/medical_watch/medical_watch_article_card.dart';
import 'package:medicail/widget/medical_watch/specialty_filter_bar.dart';

class MedicalWatchPage extends StatelessWidget {
  const MedicalWatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MedicalWatchBloc>()
        ..add(const MedicalWatchArticlesRequested()),
      child: const _MedicalWatchView(),
    );
  }
}

class _MedicalWatchView extends StatefulWidget {
  const _MedicalWatchView();

  @override
  State<_MedicalWatchView> createState() => _MedicalWatchViewState();
}

class _MedicalWatchViewState extends State<_MedicalWatchView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    context.read<MedicalWatchBloc>().add(MedicalWatchSearchRequested(query));
  }

  void _onSearchCleared() {
    _searchController.clear();
    context.read<MedicalWatchBloc>().add(const MedicalWatchSearchCleared());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<MedicalWatchBloc, MedicalWatchState>(
      listener: (context, state) {
        if (state is MedicalWatchFailure) {
          AppToast.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is MedicalWatchLoading;
        final loadedState =
            state is MedicalWatchLoaded ? state : null;
        final articles = loadedState?.articles ?? [];
        final isSearchMode = loadedState?.isSearchMode ?? false;

        return AppScaffold(
          title: l10n.medicalWatchTitle,
          actions: [
            IconButton(
              icon: const Icon(Icons.sync),
              tooltip: l10n.medicalWatchSyncSuccess,
              onPressed: () {
                context
                    .read<MedicalWatchBloc>()
                    .add(const MedicalWatchRefreshRequested());
                AppToast.showSuccess(context, l10n.medicalWatchSyncSuccess);
              },
            ),
          ],
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppInput(
                variant: AppInputVariant.text,
                label: l10n.medicalWatchSearchPlaceholder,
                controller: _searchController,
                prefixIcon: Icons.search,
                textInputAction: TextInputAction.search,
                onFieldSubmitted: _onSearchSubmitted,
                onChanged: (value) {
                  if (value.isEmpty && isSearchMode) {
                    _onSearchCleared();
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              if (!isSearchMode) ...[
                SpecialtyFilterBar(
                  selected: loadedState?.selectedSpecialty,
                  onSelected: (specialty) => context
                      .read<MedicalWatchBloc>()
                      .add(MedicalWatchSpecialtyChanged(specialty)),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      isSearchMode ? 'Résultats PubMed' : 'Derniers articles',
                      variant: AppTextVariant.title,
                    ),
                    if (loadedState != null)
                      AppText(
                        l10n.medicalWatchArticleCount(articles.length),
                        variant: AppTextVariant.caption,
                        color: context.secondaryTextColor,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading && articles.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : articles.isEmpty
                        ? Center(
                            child: AppText(
                              isSearchMode
                                  ? l10n.medicalWatchSearchEmpty
                                  : l10n.medicalWatchEmpty,
                              variant: AppTextVariant.body,
                              color: context.secondaryTextColor,
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              context
                                  .read<MedicalWatchBloc>()
                                  .add(const MedicalWatchRefreshRequested());
                              await context.read<MedicalWatchBloc>().stream.firstWhere((s) => s is! MedicalWatchLoading);
                            },
                            child: _ArticleList(
                              articles: articles,
                              padding: MainShellScope.scrollPaddingOf(context),
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ArticleList extends StatelessWidget {
  const _ArticleList({required this.articles, required this.padding});

  final List<MedicalWatchArticle> articles;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final columns = AppLayout.gridColumnCount(context);

    if (columns <= 1) {
      return ListView.separated(
        padding: padding,
        itemCount: articles.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          return MedicalWatchArticleCard(article: articles[index]);
        },
      );
    }

    return GridView.builder(
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.5,
      ),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        return MedicalWatchArticleCard(article: articles[index]);
      },
    );
  }
}
