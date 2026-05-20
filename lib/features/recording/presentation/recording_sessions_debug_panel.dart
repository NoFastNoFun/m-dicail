import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/buttons/app_button.dart';

class RecordingSessionsDebugPanel extends StatefulWidget {
  const RecordingSessionsDebugPanel({
    super.key,
    required this.repository,
  });

  final RecordingSessionRepository repository;

  @override
  State<RecordingSessionsDebugPanel> createState() =>
      _RecordingSessionsDebugPanelState();
}

class _RecordingSessionsDebugPanelState
    extends State<RecordingSessionsDebugPanel> {
  late Future<List<RecordingSession>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = widget.repository.getAll();
  }

  void _reload() {
    setState(() {
      _sessionsFuture = widget.repository.getAll();
    });
  }

  Future<void> _clearSessions() async {
    await widget.repository.clear();
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RecordingSession>>(
      future: _sessionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final sessions = snapshot.data ?? const [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Rafraichir',
                    style: AppButtonStyle.secondary,
                    onPressed: _reload,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: 'Vider',
                    style: AppButtonStyle.error,
                    enabled: sessions.isNotEmpty,
                    onPressed: _clearSessions,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (sessions.isEmpty)
              const AppText(
                'Aucune session persistee',
                variant: AppTextVariant.body,
                color: AppColors.textSecondary,
              )
            else
              for (final session in sessions) ...[
                _RecordingSessionDebugItem(session: session),
                const SizedBox(height: AppSpacing.md),
              ],
          ],
        );
      },
    );
  }
}

class _RecordingSessionDebugItem extends StatelessWidget {
  const _RecordingSessionDebugItem({required this.session});

  final RecordingSession session;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadius.mdBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              session.id,
              variant: AppTextVariant.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              'Statut: ${session.status.name}',
              variant: AppTextVariant.caption,
            ),
            AppText(
              'Debut: ${session.startedAt.toLocal()}',
              variant: AppTextVariant.caption,
            ),
            AppText(
              'Fin: ${session.endedAt?.toLocal() ?? '-'}',
              variant: AppTextVariant.caption,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              'Audio: ${session.rawAudioPath ?? '-'}',
              variant: AppTextVariant.caption,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              session.transcript.isEmpty
                  ? 'Transcription vide'
                  : session.transcript,
              variant: AppTextVariant.body,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
