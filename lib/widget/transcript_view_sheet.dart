import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_bottom_sheet.dart';

class TranscriptViewSheet extends StatelessWidget {
  const TranscriptViewSheet({
    super.key,
    required this.transcript,
    required this.recordedAt,
  });

  final String transcript;
  final DateTime recordedAt;

  static Future<void> show(
    BuildContext context, {
    required String transcript,
    required DateTime recordedAt,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.lgBorder,
      ),
      constraints: AppBottomSheet.sheetConstraints(context),
      builder: (context) => TranscriptViewSheet(
        transcript: transcript,
        recordedAt: recordedAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = l10n.localeName;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
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
                          AppText(
                            l10n.patientDossierTranscriptTitle,
                            variant: AppTextVariant.headline,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          AppText(
                            DateFormat('dd/MM/yyyy HH:mm', locale)
                                .format(recordedAt.toLocal()),
                            variant: AppTextVariant.caption,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
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
      },
    );
  }
}
