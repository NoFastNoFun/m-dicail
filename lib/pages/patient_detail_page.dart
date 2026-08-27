import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicail/features/patient/presentation/detail/patient_detail_bloc.dart';
import 'package:medicail/features/patient/presentation/detail/patient_detail_event.dart';
import 'package:medicail/features/patient/presentation/detail/patient_detail_state.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/patient_creation_sheet.dart';
import 'package:medicail/widget/soap_note_bottom_sheet.dart';
import 'package:medicail/widget/feedback/app_showcase.dart';
import 'package:medicail/features/tutorial/domain/tutorial_flow.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_bloc.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_state.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_step_extensions.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_showcase_launcher.dart';

Future<void> _openConsultationRecord(
  BuildContext context, {
  required String patientId,
  required VoidCallback onRefresh,
}) async {
  final tutorialBloc = context.read<TutorialBloc>();
  if (tutorialBloc.isCurrentStep(TutorialStepId.patientConsultation)) {
    tutorialBloc.completeStep(TutorialStepId.patientConsultation);
    await tutorialBloc.stream.firstWhere(
      (state) =>
          state is TutorialInProgress &&
          state.currentStep >=
              TutorialFlow.indexOf(TutorialStepId.recordFromPatient),
    );
  }
  if (!context.mounted) return;
  await context.goRecord(patientId: patientId);
  onRefresh();
}

class PatientDetailPage extends StatelessWidget {
  const PatientDetailPage({super.key, required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<PatientDetailBloc>()..add(PatientDetailRequested(patientId)),
      child: const _PatientDetailContent(),
    );
  }
}

class _PatientDetailContent extends StatefulWidget {
  const _PatientDetailContent();

  @override
  State<_PatientDetailContent> createState() => _PatientDetailContentState();
}

class _PatientDetailContentState extends State<_PatientDetailContent> {
  final _consultKey = GlobalKey();
  final _startedTutorialSteps = <TutorialStepId>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _handleTutorialState(context.read<TutorialBloc>().state);
    });
  }

  void _handleTutorialState(TutorialState state) {
    final stepId = state.tutorialStepId;
    if (stepId != TutorialStepId.patientConsultation) return;
    if (_startedTutorialSteps.contains(stepId)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final started = await TutorialShowcaseLauncher.startWhenReady(
        context: context,
        key: _consultKey,
      );
      if (started && mounted) {
        _startedTutorialSteps.add(TutorialStepId.patientConsultation);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<PatientDetailBloc, PatientDetailState>(
      builder: (context, state) {
        final patient = state is PatientDetailLoaded ? state.patient : null;
        final sessions = state is PatientDetailLoaded
            ? state.sessions
            : <RecordingSession>[];
        final isLoading =
            state is PatientDetailLoading || state is PatientDetailInitial;

        return AppScaffold(
          title: l10n.patientDetailTitle,
          actions: patient == null
              ? null
              : [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Modifier le patient',
                    onPressed: () {
                      PatientCreationSheet.show(
                        context,
                        initialPatient: patient,
                        onSuccess: (_) {
                          context.read<PatientDetailBloc>().add(
                            PatientDetailRequested(patient.id),
                          );
                        },
                      );
                    },
                  ),
                ],
          body: BlocListener<TutorialBloc, TutorialState>(
            listener: (context, state) => _handleTutorialState(state),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : patient == null
                ? Center(
                    child: AppText(
                      l10n.patientNotFound,
                      variant: AppTextVariant.body,
                      color: context.secondaryTextColor,
                    ),
                  )
                : _PatientDetailView(
                    patient: patient,
                    sessions: sessions,
                    consultKey: _consultKey,
                    onRefresh: () {
                      context.read<PatientDetailBloc>().add(
                        PatientDetailRequested(patient.id),
                      );
                    },
                  ),
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
    required this.consultKey,
    required this.onRefresh,
  });

  final Patient patient;
  final List<RecordingSession> sessions;
  final GlobalKey consultKey;
  final VoidCallback onRefresh;

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      children: [
        AppText(patient.displayName, variant: AppTextVariant.headline),
        const SizedBox(height: AppSpacing.sm),
        AppText(
          'MRN: ${patient.mrn}',
          variant: AppTextVariant.caption,
          color: context.secondaryTextColor,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.md),
        if (patient.birthDate != null || patient.sex != null) ...[
          Row(
            children: [
              if (patient.birthDate != null) ...[
                Icon(Icons.cake_outlined, size: 16, color: context.secondaryTextColor),
                const SizedBox(width: AppSpacing.xs),
                AppText(
                  '${DateFormat.yMd(l10n.localeName).format(patient.birthDate!)} (${_calculateAge(patient.birthDate!)} ans)',
                  variant: AppTextVariant.caption,
                  color: context.secondaryTextColor,
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              if (patient.sex != null) ...[
                Icon(Icons.person_outline, size: 16, color: context.secondaryTextColor),
                const SizedBox(width: AppSpacing.xs),
                AppText(
                  patient.sex!,
                  variant: AppTextVariant.caption,
                  color: context.secondaryTextColor,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        if (patient.contact?.phone != null || patient.contact?.email != null) ...[
          Row(
            children: [
              if (patient.contact?.phone != null) ...[
                Icon(Icons.phone_outlined, size: 16, color: context.secondaryTextColor),
                const SizedBox(width: AppSpacing.xs),
                AppText(
                  patient.contact!.phone!,
                  variant: AppTextVariant.caption,
                  color: context.secondaryTextColor,
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              if (patient.contact?.email != null) ...[
                Icon(Icons.email_outlined, size: 16, color: context.secondaryTextColor),
                const SizedBox(width: AppSpacing.xs),
                AppText(
                  patient.contact!.email!,
                  variant: AppTextVariant.caption,
                  color: context.secondaryTextColor,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        if (patient.contact?.address != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.home_outlined, size: 16, color: context.secondaryTextColor),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: AppText(
                  patient.contact!.address!,
                  variant: AppTextVariant.caption,
                  color: context.secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        if (patient.notes != null && patient.notes!.isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.note_alt_outlined, size: 16, color: context.secondaryTextColor),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: AppText(
                  patient.notes!,
                  variant: AppTextVariant.caption,
                  color: context.secondaryTextColor,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppShowcase(
          key: consultKey,
          title: l10n.tutorialDetailConsultTitle,
          description: l10n.tutorialDetailConsultDesc,
          disposeOnTap: false,
          disableBarrierInteraction: true,
          onTargetClick: () => _openConsultationRecord(
            context,
            patientId: patient.id,
            onRefresh: onRefresh,
          ),
          child: AppButton(
            label: l10n.patientNewConsultationButton,
            onPressed: () => _openConsultationRecord(
              context,
              patientId: patient.id,
              onRefresh: onRefresh,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppText(l10n.patientSessionsTitle, variant: AppTextVariant.title),
        const SizedBox(height: AppSpacing.sm),
        if (sessions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: AppText(
                l10n.patientSessionsEmpty,
                variant: AppTextVariant.body,
                color: context.secondaryTextColor,
              ),
            ),
          )
        else
          ...sessions.map(
            (session) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _RecordingSessionListItem(
                session: session,
                onRefresh: onRefresh,
              ),
            ),
          ),
      ],
    );
  }
}

class _RecordingSessionListItem extends StatelessWidget {
  const _RecordingSessionListItem({
    required this.session,
    required this.onRefresh,
  });

  final RecordingSession session;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasSoap = session.soapNote != null;
    final theme = Theme.of(context);

    final statusLabel = switch (session.status) {
      RecordingSessionStatus.draft => l10n.sessionStatusDraft,
      RecordingSessionStatus.recording => l10n.sessionStatusRecording,
      RecordingSessionStatus.completed => l10n.sessionStatusCompleted,
      RecordingSessionStatus.failed => l10n.sessionStatusFailed,
    };

    return InkWell(
      onTap: () {
        final initialNote = session.soapNote ?? const SoapNote();
        SoapNoteBottomSheet.show(
          context,
          initialNote: initialNote,
          transcript: session.transcript,
          onSave: (updatedNote) async {
            final repo = getIt<RecordingSessionRepository>();
            await repo.save(
              session.copyWith(soapNote: updatedNote),
            );
            onRefresh();
          },
        );
      },
      borderRadius: AppRadius.mdBorder,
      child: Ink(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.dividerColor),
          borderRadius: AppRadius.mdBorder,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          '${l10n.recordingDateLabel}: ${DateFormat('dd/MM/yyyy HH:mm').format(session.startedAt.toLocal())}',
                          variant: AppTextVariant.label,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppText(
                          '${l10n.recordingStatusLabel}: $statusLabel',
                          variant: AppTextVariant.caption,
                          color: context.secondaryTextColor,
                        ),
                      ],
                    ),
                  ),
                  if (hasSoap)
                    Icon(
                      Icons.chevron_right,
                      color: context.secondaryTextColor,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
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
      ),
    );
  }
}
