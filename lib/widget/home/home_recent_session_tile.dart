import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/widget/app_text.dart';

class HomeRecentSessionTile extends StatelessWidget {
  const HomeRecentSessionTile({super.key, required this.session});

  final RecordingSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = session.endedAt != null
        ? DateFormat.yMMMd().add_Hm().format(session.endedAt!)
        : DateFormat.yMMMd().add_Hm().format(session.startedAt);
    final snippet = session.transcript.isNotEmpty
        ? session.transcript
        : AppLocalizations.of(context).transcriptEmptyFallback;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdBorder,
          side: BorderSide(color: theme.dividerColor),
        ),
        child: InkWell(
          onTap: session.patientId != null
              ? () => context.goPatientDetail(session.patientId!)
              : null,
          borderRadius: AppRadius.mdBorder,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: AppRadius.smBorder,
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        session.templateName ??
                            AppLocalizations.of(context).recordTitle,
                        variant: AppTextVariant.label,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      AppText(
                        dateStr,
                        variant: AppTextVariant.caption,
                        color: context.secondaryTextColor,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      AppText(
                        snippet,
                        variant: AppTextVariant.caption,
                        color: context.secondaryTextColor,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (session.soapNote != null)
                  Icon(
                    Icons.check_circle_outline,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
