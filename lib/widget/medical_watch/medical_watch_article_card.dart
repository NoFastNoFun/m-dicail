import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/medical_watch/domain/entities/medical_watch_article.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MedicalWatchArticleCard extends StatefulWidget {
  const MedicalWatchArticleCard({
    super.key,
    required this.article,
  });

  final MedicalWatchArticle article;

  @override
  State<MedicalWatchArticleCard> createState() => _MedicalWatchArticleCardState();
}

class _MedicalWatchArticleCardState extends State<MedicalWatchArticleCard> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  Future<void> _openPubmed() async {
    final url = widget.article.pubmedUrl;
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    }
  }

  void _copyReference(BuildContext context) {
    final authors = widget.article.authors.join(', ');
    final date = widget.article.publicationDate ?? '';
    final doiStr = widget.article.doi != null ? ' doi: ${widget.article.doi}' : '';
    final reference = '$authors. ${widget.article.title} $date.$doiStr';

    Clipboard.setData(ClipboardData(text: reference));
    final l10n = AppLocalizations.of(context);
    AppToast.showSuccess(context, l10n.medicalWatchReferenceCopied);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final article = widget.article;

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppText(
                    article.title,
                    variant: AppTextVariant.title,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_outlined, size: 20),
                  color: context.secondaryTextColor,
                  onPressed: () => _copyReference(context),
                  tooltip: l10n.medicalWatchCopyReference,
                ),
              ],
            ),
            if (article.authors.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              AppText(
                article.authors.join(', '),
                variant: AppTextVariant.caption,
                color: context.secondaryTextColor,
              ),
            ],
            if (article.publicationDate != null) ...[
              const SizedBox(height: AppSpacing.xs),
              AppText(
                article.publicationDate!,
                variant: AppTextVariant.caption,
                color: context.secondaryTextColor,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            if (article.abstract_.isNotEmpty) ...[
              AnimatedCrossFade(
                firstChild: AppText(
                  article.abstract_,
                  variant: AppTextVariant.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                secondChild: AppText(
                  article.abstract_,
                  variant: AppTextVariant.body,
                ),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: AppButton(
                  label: _isExpanded ? l10n.medicalWatchReadLess : l10n.medicalWatchReadMore,
                  style: AppButtonStyle.secondary,
                  layout: AppButtonLayout.text,
                  expanded: false,
                  onPressed: _toggleExpanded,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _openPubmed,
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: AppText(
                    l10n.medicalWatchOpenPubmed,
                    variant: AppTextVariant.caption,
                    color: theme.colorScheme.primary,
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                if (article.specialty != null)
                  const SizedBox(width: AppSpacing.sm),
                if (article.specialty != null)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: AppRadius.pillBorder,
                        ),
                        child: AppText(
                          article.specialty!.label(l10n),
                          variant: AppTextVariant.caption,
                          color: theme.colorScheme.primary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
