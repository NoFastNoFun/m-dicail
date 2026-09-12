import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_bottom_sheet.dart';
import 'package:medicail/widget/legal/app_eu_ai_label.dart';

class TranscriptViewSheet extends StatelessWidget {
  const TranscriptViewSheet({
    super.key,
    required this.transcript,
    required this.recordedAt,
    this.isAi = false,
  });

  final String transcript;
  final DateTime recordedAt;
  final bool isAi;

  static Future<void> show(
    BuildContext context, {
    required String transcript,
    required DateTime recordedAt,
    bool isAi = false,
  }) {
    return AppBottomSheet.present(
      context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      constraints: AppBottomSheet.sheetConstraints(context),
      builder: (context) => TranscriptViewSheet(
        transcript: transcript,
        recordedAt: recordedAt,
        isAi: isAi,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = l10n.localeName;
    final asDialog = AppBottomSheet.usesDialog(context);

    Widget body(ScrollController? scrollController) {
      return SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AppText(
                                l10n.patientDossierTranscriptTitle,
                                variant: AppTextVariant.headline,
                              ),
                            ),
                            if (isAi) ...[
                              const SizedBox(width: AppSpacing.sm),
                              const AppEuAiLabel(
                                kind: EuAiLabelKind.generated,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        AppText(
                          DateFormat('dd/MM/yyyy HH:mm', locale)
                              .format(recordedAt.toLocal()),
                          variant: AppTextVariant.caption,
                          color: context.secondaryTextColor,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: context.secondaryTextColor,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AppText(
                  transcript.isEmpty
                      ? l10n.transcriptEmptyFallback
                      : transcript,
                  variant: AppTextVariant.body,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (asDialog) {
      return SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: body(null),
      );
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => body(scrollController),
    );
  }
}
