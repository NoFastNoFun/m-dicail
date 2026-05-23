import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';
import 'package:medicail/features/templates/domain/entities/template_list_item.dart';
import 'package:medicail/features/templates/presentation/template_bloc.dart';
import 'package:medicail/features/templates/presentation/template_event.dart';
import 'package:medicail/features/templates/presentation/template_state.dart';
import 'package:medicail/widget/app_badge.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/inputs/app_input.dart';

class TemplatePickerSheet extends StatefulWidget {
  const TemplatePickerSheet({
    super.key,
    required this.onTemplateApplied,
  });

  final void Function(SoapNote note, {String? baseTemplateId}) onTemplateApplied;

  static Future<void> show(
    BuildContext context, {
    required void Function(SoapNote note, {String? baseTemplateId}) onTemplateApplied,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return BlocProvider(
          create: (_) =>
              getIt<TemplateBloc>()..add(const TemplatesLoadRequested()),
          child: TemplatePickerSheet(onTemplateApplied: onTemplateApplied),
        );
      },
    );
  }

  @override
  State<TemplatePickerSheet> createState() => _TemplatePickerSheetState();
}

class _TemplatePickerSheetState extends State<TemplatePickerSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final height = MediaQuery.sizeOf(context).height * 0.85;

    return SizedBox(
      height: height,
      child: BlocConsumer<TemplateBloc, TemplateState>(
        listener: (context, state) {
          if (state is TemplateLoaded && state.selectedNote != null) {
            widget.onTemplateApplied(
              state.selectedNote!,
              baseTemplateId: state.selectedBaseTemplateId,
            );
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    0,
                  ),
                  child: AppText(
                    l10n.templatePickerTitle,
                    variant: AppTextVariant.title,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: AppInput(
                    variant: AppInputVariant.text,
                    controller: _searchController,
                    hint: l10n.templatePickerSearchHint,
                    onChanged: (value) {
                      context.read<TemplateBloc>().add(
                            TemplateSearchQueryChanged(value),
                          );
                    },
                  ),
                ),
                Expanded(child: _buildList(context, state, l10n)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    TemplateState state,
    AppLocalizations l10n,
  ) {
    if (state is TemplateLoading || state is TemplateInitial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is TemplateError) {
      return Center(
        child: AppText(state.message, variant: AppTextVariant.body),
      );
    }
    if (state is! TemplateLoaded) {
      return const SizedBox.shrink();
    }

    if (state.items.isEmpty) {
      return Center(
        child: AppText(
          l10n.templatePickerSearchHint,
          variant: AppTextVariant.body,
          color: AppColors.textSecondary,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: state.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final item = state.items[index];
        return _TemplateListTile(
          item: item,
          builtinLabel: l10n.templateBadgeBuiltin,
          variantLabel: l10n.templateBadgeVariant,
          onTap: () {
            context.read<TemplateBloc>().add(TemplateSelected(item.id));
          },
        );
      },
    );
  }

}

class _TemplateListTile extends StatelessWidget {
  const _TemplateListTile({
    required this.item,
    required this.builtinLabel,
    required this.variantLabel,
    required this.onTap,
  });

  final TemplateListItem item;
  final String builtinLabel;
  final String variantLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final badgeVariant = item.type == TemplateItemType.builtin
        ? AppBadgeVariant.builtin
        : AppBadgeVariant.variant;
    final badgeLabel =
        item.type == TemplateItemType.builtin ? builtinLabel : variantLabel;

    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: AppText(
                  item.displayName,
                  variant: AppTextVariant.body,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppBadge(label: badgeLabel, variant: badgeVariant),
            ],
          ),
        ),
      ),
    );
  }
}
