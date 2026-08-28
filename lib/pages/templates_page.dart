import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/layout/main_shell_chrome.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/features/note_template/domain/repositories/note_template_repository.dart';
import 'package:medicail/features/pathology/domain/entities/pathology.dart';
import 'package:medicail/features/pathology/domain/entities/pathology_domain.dart';
import 'package:medicail/features/pathology/domain/entities/pathology_source.dart';
import 'package:medicail/features/pathology/domain/utils/pathology_labels.dart';
import 'package:medicail/features/pathology/presentation/pathology_bloc.dart';
import 'package:medicail/features/pathology/domain/repositories/pathology_repository.dart';
import 'package:medicail/features/pathology/presentation/pathology_event.dart';
import 'package:medicail/features/pathology/presentation/pathology_state.dart';
import 'package:medicail/pages/pathology_create_page.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_dialog.dart';
import 'package:medicail/widget/feedback/app_toast.dart';

class TemplatesPage extends StatelessWidget {
  const TemplatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PathologyBloc>()..add(const PathologiesRequested()),
      child: const _TemplatesView(),
    );
  }
}

class _TemplatesView extends StatelessWidget {
  const _TemplatesView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.templatesTitle,
      actions: [
        IconButton(
          tooltip: l10n.templateCreateAction,
          onPressed: () => openPathologyCreatePage(context),
          icon: const Icon(Icons.add),
        ),
      ],
      body: BlocConsumer<PathologyBloc, PathologyState>(
        listener: (context, state) {
          if (state is PathologyFailure) {
            AppToast.show(context, message: state.message);
          }
          if (state is PathologyActionSuccess && state.message == 'created') {
            AppToast.showSuccess(context, l10n.templateSaved);
          }
        },
        builder: (context, state) {
          return switch (state) {
            PathologyInitial() || PathologyLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            PathologyLoaded(
              :final builtInPathologies,
              :final userPathologies,
            ) ||
            PathologyActionSuccess(
              :final builtInPathologies,
              :final userPathologies,
            ) =>
              _PathologiesList(
                builtInPathologies: builtInPathologies,
                userPathologies: userPathologies,
              ),
            PathologyFailure(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(message, variant: AppTextVariant.body),
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(
                        label: l10n.templateRetry,
                        onPressed: () => context
                            .read<PathologyBloc>()
                            .add(const PathologiesRequested()),
                      ),
                    ],
                  ),
                ),
              ),
          };
        },
      ),
    );
  }
}

Future<void> openPathologyCreatePage(BuildContext context) async {
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (innerContext) => BlocProvider.value(
        value: context.read<PathologyBloc>(),
        child: PathologyCreatePage(
          onCreate: (name, domain) async {
            await getIt<PathologyRepository>().createUserPathology(
              name: name,
              domain: domain,
            );
            if (context.mounted) {
              context.read<PathologyBloc>().add(const PathologiesRequested());
            }
          },
        ),
      ),
    ),
  );
}

class _PathologiesList extends StatelessWidget {
  const _PathologiesList({
    required this.builtInPathologies,
    required this.userPathologies,
  });

  final List<Pathology> builtInPathologies;
  final List<Pathology> userPathologies;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groupedBuiltIn = _groupByDomain(builtInPathologies);

    return ListView(
      padding: MainShellScope.scrollPaddingOf(context),
      children: [
        AppButton(
          label: l10n.templateCreateAction,
          style: AppButtonStyle.secondary,
          layout: AppButtonLayout.textWithIcon,
          icon: Icons.add,
          onPressed: () => openPathologyCreatePage(context),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppText(
          l10n.templatesBuiltInSection,
          variant: AppTextVariant.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (builtInPathologies.isEmpty)
          AppText(
            l10n.templatesBuiltInEmpty,
            variant: AppTextVariant.caption,
          )
        else
          ...groupedBuiltIn.entries.expand(
            (entry) => [
              AppText(entry.key.labelFr(), variant: AppTextVariant.caption),
              const SizedBox(height: AppSpacing.sm),
              ...entry.value.map(
                (pathology) => _PathologyListTile(
                  pathology: pathology,
                  onCustomizeSoap: () => _openSoapEditor(context, pathology),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        const SizedBox(height: AppSpacing.xl),
        AppText(
          l10n.templatesUserSection,
          variant: AppTextVariant.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (userPathologies.isEmpty)
          AppText(
            l10n.templatesUserEmpty,
            variant: AppTextVariant.caption,
          )
        else
          ...userPathologies.map(
            (pathology) => _PathologyListTile(
              pathology: pathology,
              onCustomizeSoap: () => _openSoapEditor(context, pathology),
              onDelete: pathology.source == PathologySource.builtIn
                  ? null
                  : () => _deletePathology(context, pathology),
            ),
          ),
      ],
    );
  }

  Map<PathologyDomain, List<Pathology>> _groupByDomain(List<Pathology> items) {
    final grouped = <PathologyDomain, List<Pathology>>{};
    for (final pathology in items) {
      grouped.putIfAbsent(pathology.domain, () => []).add(pathology);
    }
    return {
      for (final domain in PathologyDomain.values)
        if (grouped.containsKey(domain)) domain: grouped[domain]!,
    };
  }

  Future<void> _openSoapEditor(BuildContext context, Pathology pathology) async {
    final templateRepository = getIt<NoteTemplateRepository>();
    NoteTemplate? template;
    final templateId = pathology.templateId;
    if (templateId != null && templateId.isNotEmpty) {
      template = await templateRepository.getById(templateId);
    }

    if (!context.mounted) {
      return;
    }

    if (template != null) {
      context.pushNamed(
        'template-editor',
        pathParameters: {'templateId': template.id},
        extra: template,
      );
      return;
    }

    context.pushNamed(
      'template-create',
      queryParameters: {'pathologyId': pathology.id},
    );
  }

  Future<void> _deletePathology(
    BuildContext context,
    Pathology pathology,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppDialog.show<bool>(
      context,
      variant: AppDialogVariant.standard,
      title: l10n.templateDeleteTitle,
      body: AppText(
        l10n.templateDeleteMessage(pathology.name),
        variant: AppTextVariant.body,
      ),
      actionsBuilder: (dialogContext) => [
        AppButton(
          label: l10n.recordLeaveCancel,
          style: AppButtonStyle.secondary,
          expanded: false,
          onPressed: () => Navigator.of(dialogContext).pop(false),
        ),
        AppButton(
          label: l10n.templateDeleteConfirm,
          style: AppButtonStyle.error,
          expanded: false,
          onPressed: () => Navigator.of(dialogContext).pop(true),
        ),
      ],
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    context.read<PathologyBloc>().add(
          PathologyDeleteRequested(pathology.id),
        );
  }
}

class _PathologyListTile extends StatelessWidget {
  const _PathologyListTile({
    required this.pathology,
    required this.onCustomizeSoap,
    this.onDelete,
  });

  final Pathology pathology;
  final VoidCallback onCustomizeSoap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        title: AppText(pathology.name, variant: AppTextVariant.body),
        subtitle: AppText(pathology.sourceBadgeFr(), variant: AppTextVariant.caption),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: l10n.pathologyCustomizeSoapAction,
              onPressed: onCustomizeSoap,
              icon: const Icon(Icons.description_outlined),
            ),
            if (onDelete != null)
              IconButton(
                tooltip: l10n.templateDeleteConfirm,
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
          ],
        ),
        onTap: onCustomizeSoap,
      ),
    );
  }
}
