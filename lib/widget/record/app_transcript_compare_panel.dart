import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/app_typography.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/utils/transcript_word_diff.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/legal/app_eu_ai_label.dart';

class AppTranscriptComparePanel extends StatefulWidget {
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

  static const double _sideBySideMinWidth = 700;

  @override
  State<AppTranscriptComparePanel> createState() =>
      _AppTranscriptComparePanelState();
}

class _AppTranscriptComparePanelState extends State<AppTranscriptComparePanel> {
  final ScrollController _localScrollController = ScrollController();
  final ScrollController _aiScrollController = ScrollController();
  bool _syncingScroll = false;

  @override
  void dispose() {
    _localScrollController.dispose();
    _aiScrollController.dispose();
    super.dispose();
  }

  void _syncScroll({
    required ScrollController source,
    required ScrollController target,
  }) {
    if (_syncingScroll) return;
    if (!source.hasClients || !target.hasClients) return;

    final sourceMax = source.position.maxScrollExtent;
    final targetMax = target.position.maxScrollExtent;
    if (sourceMax <= 0 && targetMax <= 0) return;

    final ratio = sourceMax <= 0 ? 0.0 : (source.offset / sourceMax);
    final nextOffset =
        (ratio * targetMax).clamp(0.0, targetMax > 0 ? targetMax : 0.0);
    if ((target.offset - nextOffset).abs() < 0.5) return;

    _syncingScroll = true;
    target.jumpTo(nextOffset);
    _syncingScroll = false;
  }

  bool _onLocalScroll(ScrollNotification notification) {
    if (notification is! ScrollUpdateNotification) return false;
    _syncScroll(source: _localScrollController, target: _aiScrollController);
    return false;
  }

  bool _onAiScroll(ScrollNotification notification) {
    if (notification is! ScrollUpdateNotification) return false;
    _syncScroll(source: _aiScrollController, target: _localScrollController);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final diff = TranscriptWordDiff.compare(
      widget.localTranscript,
      widget.aiTranscript,
    );
    final localEmpty = widget.localTranscript.trim().isEmpty;
    final aiEmpty = widget.aiTranscript.trim().isEmpty;

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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final sideBySide =
                        constraints.maxWidth >=
                        AppTranscriptComparePanel._sideBySideMinWidth;
                    final localColumn = _CompareColumn(
                      title: l10n.recordTranscriptCompareLocal,
                      titleIcon: Icons.mic_none_outlined,
                      transcript: widget.localTranscript,
                      spans: localEmpty ? const [] : diff.left,
                      emptyLabel: l10n.transcriptEmptyFallback,
                      buttonLabel: l10n.recordTranscriptCompareChooseLocal,
                      onChoose: widget.onSelectLocal,
                      scrollController: _localScrollController,
                      onScrollNotification: _onLocalScroll,
                    );
                    final aiColumn = _CompareColumn(
                      title: l10n.recordTranscriptCompareAi,
                      titleIcon: Icons.auto_awesome,
                      transcript: widget.aiTranscript,
                      spans: aiEmpty ? const [] : diff.right,
                      emptyLabel: l10n.transcriptEmptyFallback,
                      buttonLabel: l10n.recordTranscriptCompareChooseAi,
                      onChoose: widget.onSelectAi,
                      emphasize: true,
                      showEuAiLabel: true,
                      scrollController: _aiScrollController,
                      onScrollNotification: _onAiScroll,
                    );

                    if (sideBySide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: localColumn),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(child: aiColumn),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: localColumn),
                        const SizedBox(height: AppSpacing.md),
                        Expanded(child: aiColumn),
                      ],
                    );
                  },
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
    required this.spans,
    required this.emptyLabel,
    required this.buttonLabel,
    required this.onChoose,
    required this.scrollController,
    required this.onScrollNotification,
    this.emphasize = false,
    this.showEuAiLabel = false,
  });

  final String title;
  final IconData titleIcon;
  final String transcript;
  final List<TranscriptDiffSpan> spans;
  final String emptyLabel;
  final String buttonLabel;
  final VoidCallback onChoose;
  final ScrollController scrollController;
  final NotificationListenerCallback<ScrollNotification> onScrollNotification;
  final bool emphasize;
  final bool showEuAiLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = emphasize
        ? theme.colorScheme.primary.withValues(alpha: 0.55)
        : theme.dividerColor;
    final isEmpty = transcript.trim().isEmpty;

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
            if (showEuAiLabel) ...[
              const SizedBox(height: AppSpacing.sm),
              const Align(
                alignment: Alignment.centerLeft,
                child: AppEuAiLabel(kind: EuAiLabelKind.generated),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: onScrollNotification,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: isEmpty
                      ? AppText(
                          emptyLabel,
                          variant: AppTextVariant.body,
                        )
                      : _AppTranscriptDiffText(spans: spans),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: isEmpty ? null : onChoose,
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppTranscriptDiffText extends StatelessWidget {
  const _AppTranscriptDiffText({required this.spans});

  final List<TranscriptDiffSpan> spans;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = AppTypography.body.copyWith(
      color: theme.textTheme.bodyLarge?.color ??
          theme.colorScheme.onSurface,
      decoration: TextDecoration.none,
      decorationColor: Colors.transparent,
      decorationThickness: 0,
    );
    final highlightStyle = baseStyle.copyWith(
      fontWeight: FontWeight.w600,
      backgroundColor: AppColors.warning.withValues(alpha: 0.45),
    );

    return Text.rich(
      TextSpan(
        children: [
          for (final span in spans)
            TextSpan(
              text: span.text,
              style: span.isDifferent ? highlightStyle : baseStyle,
            ),
        ],
      ),
    );
  }
}
