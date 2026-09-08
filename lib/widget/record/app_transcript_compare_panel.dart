import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/widget/app_text.dart';

class AppTranscriptComparePanel extends StatelessWidget {
  const AppTranscriptComparePanel({
    super.key,
    required this.localTranscript,
    required this.aiTranscript,
    required this.onSelectLocal,
    required this.onSelectAi,
  });

  final String localTranscript;
  final String aiTranscript;
  final VoidCallback onSelectLocal;
  final VoidCallback onSelectAi;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(
                l10n.recordTranscriptCompareTitle,
                variant: AppTextVariant.headline,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppText(
                l10n.recordTranscriptCompareHint,
                variant: AppTextVariant.caption,
                color: context.secondaryTextColor,
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _CompareColumn(
                        title: l10n.recordTranscriptCompareLocal,
                        titleIcon: Icons.mic_none_outlined,
                        transcript: localTranscript,
                        buttonLabel: l10n.recordTranscriptCompareChooseLocal,
                        onChoose: onSelectLocal,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _CompareColumn(
                        title: l10n.recordTranscriptCompareAi,
                        titleIcon: Icons.auto_awesome,
                        transcript: aiTranscript,
                        buttonLabel: l10n.recordTranscriptCompareChooseAi,
                        onChoose: onSelectAi,
                        emphasize: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompareColumn extends StatelessWidget {
  const _CompareColumn({
    required this.title,
    required this.titleIcon,
    required this.transcript,
    required this.buttonLabel,
    required this.onChoose,
    this.emphasize = false,
  });

  final String title;
  final IconData titleIcon;
  final String transcript;
  final String buttonLabel;
  final VoidCallback onChoose;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = emphasize
        ? theme.colorScheme.primary.withValues(alpha: 0.55)
        : theme.dividerColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  titleIcon,
                  size: 18,
                  color: emphasize
                      ? theme.colorScheme.primary
                      : context.secondaryTextColor,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: AppText(
                    title,
                    variant: AppTextVariant.label,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: SingleChildScrollView(
                child: AppText(
                  transcript.trim().isEmpty
                      ? AppLocalizations.of(context).transcriptEmptyFallback
                      : transcript,
                  variant: AppTextVariant.body,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: transcript.trim().isEmpty ? null : onChoose,
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
