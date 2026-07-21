import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/layout/main_shell_chrome.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/features/note_template/presentation/note_template_bloc.dart';
import 'package:medicail/features/note_template/presentation/note_template_event.dart';
import 'package:medicail/features/note_template/presentation/note_template_state.dart';
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
      create: (_) =>
          getIt<NoteTemplateBloc>()..add(const NoteTemplatesRequested()),
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
      body: BlocConsumer<NoteTemplateBloc, NoteTemplateState>(
        listener: (context, state) {
          if (state is NoteTemplateFailure) {
            AppToast.show(context, message: state.message);
          }
          if (state is NoteTemplateActionSuccess &&
              state.message == 'duplicated' &&
              state.savedTemplateId != null) {
            final variant = _findTemplateById(
              state.userVariants,
              state.savedTemplateId!,
            );
            if (variant == null) {
              return;
            }
            context.pushNamed(
              'template-editor',
              pathParameters: {'templateId': variant.id},
              extra: variant,
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            NoteTemplateInitial() || NoteTemplateLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            NoteTemplateLoaded(
              :final builtInTemplates,
              :final userVariants,
            ) ||
            NoteTemplateActionSuccess(
              :final builtInTemplates,
              :final userVariants,
            ) =>
              _TemplatesList(
                builtInTemplates: builtInTemplates,
                userVariants: userVariants,
              ),
            NoteTemplateFailure(:final message) => Center(
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
                            .read<NoteTemplateBloc>()
                            .add(const NoteTemplatesRequested()),
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

NoteTemplate? _findTemplateById(List<NoteTemplate> templates, String id) {
  for (final template in templates) {
    if (template.id == id) {
      return template;
    }
  }
  return null;
}

class _TemplatesList extends StatelessWidget {
  const _TemplatesList({
    required this.builtInTemplates,
    required this.userVariants,
  });

  final List<NoteTemplate> builtInTemplates;
  final List<NoteTemplate> userVariants;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: MainShellScope.scrollPaddingOf(context),
      children: [
        AppText(
          l10n.templatesBuiltInSection,
          variant: AppTextVariant.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (builtInTemplates.isEmpty)
          AppText(
            l10n.templatesBuiltInEmpty,
            variant: AppTextVariant.caption,
          )
        else
          ...builtInTemplates.map(
          (template) => _TemplateListTile(
            template: template,
            badge: l10n.templatesDefaultBadge,
            onTap: () => context.pushNamed(
              'template-editor',
              pathParameters: {'templateId': template.id},
              extra: template,
            ),
            onDuplicate: () => _duplicateTemplate(context, template),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppText(
          l10n.templatesUserSection,
          variant: AppTextVariant.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (userVariants.isEmpty)
          AppText(
            l10n.templatesUserEmpty,
            variant: AppTextVariant.caption,
          )
        else
          ...userVariants.map(
            (template) => _TemplateListTile(
              template: template,
              badge: l10n.templatesVariantBadge,
              onTap: () => context.pushNamed(
                'template-editor',
                pathParameters: {'templateId': template.id},
                extra: template,
              ),
              onDelete: () => _deleteVariant(context, template),
            ),
          ),
      ],
    );
  }

  Future<void> _duplicateTemplate(
    BuildContext context,
    NoteTemplate template,
  ) async {
    final l10n = AppLocalizations.of(context);
    final name = '${template.name} (${l10n.templatesVariantBadge})';
    context.read<NoteTemplateBloc>().add(
          NoteTemplateDuplicateRequested(
            parentTemplateId: template.id,
            name: name,
          ),
        );
  }

  Future<void> _deleteVariant(
    BuildContext context,
    NoteTemplate template,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppDialog.show<bool>(
      context,
      variant: AppDialogVariant.standard,
      title: l10n.templateDeleteTitle,
      body: AppText(
        l10n.templateDeleteMessage(template.name),
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
    context.read<NoteTemplateBloc>().add(
          NoteTemplateDeleteRequested(template.id),
        );
  }
}

class _TemplateListTile extends StatelessWidget {
  const _TemplateListTile({
    required this.template,
    required this.badge,
    required this.onTap,
    this.onDuplicate,
    this.onDelete,
  });

  final NoteTemplate template;
  final String badge;
  final VoidCallback onTap;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        title: AppText(template.name, variant: AppTextVariant.body),
        subtitle: AppText(badge, variant: AppTextVariant.caption),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onDuplicate != null)
              IconButton(
                tooltip: l10n.templateDuplicateAction,
                onPressed: onDuplicate,
                icon: const Icon(Icons.edit_outlined),
              ),
            if (onDelete != null)
              IconButton(
                tooltip: l10n.templateDeleteConfirm,
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
