import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/patient/domain/repositories/patient_repository.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';

class PatientDetailPage extends StatefulWidget {
  const PatientDetailPage({
    super.key,
    required this.patientId,
  });

  final String patientId;

  @override
  State<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> {
  late Future<_PatientDetailData> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _loadDetail();
  }

  Future<_PatientDetailData> _loadDetail() async {
    final patientRepository = getIt<PatientRepository>();
    final recordingRepository = getIt<RecordingSessionRepository>();
    final patient = await patientRepository.getById(widget.patientId);
    final sessions = await recordingRepository.getByPatientId(widget.patientId);
    return _PatientDetailData(patient: patient, sessions: sessions);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<_PatientDetailData>(
      future: _detailFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final patient = data?.patient;

        return AppScaffold(
          title: l10n.patientDetailTitle,
          body: snapshot.connectionState != ConnectionState.done
              ? const Center(child: CircularProgressIndicator())
              : patient == null
                  ? Center(
                      child: AppText(
                        l10n.patientNotFound,
                        variant: AppTextVariant.body,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : _PatientDetailView(
                      patient: patient,
                      sessions: data?.sessions ?? const [],
                    ),
        );
      },
    );
  }
}

class _PatientDetailView extends StatelessWidget {
  const _PatientDetailView({
    required this.patient,
    required this.sessions,
  });

  final Patient patient;
  final List<RecordingSession> sessions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(patient.displayName, variant: AppTextVariant.headline),
        const SizedBox(height: AppSpacing.sm),
        AppText(
          patient.id,
          variant: AppTextVariant.caption,
          color: AppColors.textSecondary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: l10n.patientNewConsultationButton,
          onPressed: () => context.goRecord(),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppText(
          l10n.patientSessionsTitle,
          variant: AppTextVariant.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: sessions.isEmpty
              ? Center(
                  child: AppText(
                    l10n.patientSessionsEmpty,
                    variant: AppTextVariant.body,
                    color: AppColors.textSecondary,
                  ),
                )
              : ListView.separated(
                  itemCount: sessions.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    return _RecordingSessionListItem(session: sessions[index]);
                  },
                ),
        ),
      ],
    );
  }
}

class _RecordingSessionListItem extends StatelessWidget {
  const _RecordingSessionListItem({required this.session});

  final RecordingSession session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
              session.startedAt.toLocal().toString(),
              variant: AppTextVariant.label,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              '${l10n.recordingStatusLabel}: ${session.status.name}',
              variant: AppTextVariant.caption,
              color: AppColors.textSecondary,
            ),
            AppText(
              '${l10n.recordingAudioLabel}: ${session.rawAudioPath ?? '-'}',
              variant: AppTextVariant.caption,
              color: AppColors.textSecondary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              session.transcript.isEmpty
                  ? l10n.transcriptEmptyFallback
                  : session.transcript,
              variant: AppTextVariant.body,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientDetailData {
  const _PatientDetailData({
    required this.patient,
    required this.sessions,
  });

  final Patient? patient;
  final List<RecordingSession> sessions;
}
