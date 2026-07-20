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
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicail/features/patient/presentation/detail/patient_detail_bloc.dart';
import 'package:medicail/features/patient/presentation/detail/patient_detail_event.dart';
import 'package:medicail/features/patient/presentation/detail/patient_detail_state.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/exo_patient/exo_patient_section.dart';
import 'package:medicail/widget/soap_note_bottom_sheet.dart';
import 'package:showcaseview/showcaseview.dart';
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
          color: context.secondaryTextColor,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.lg),
        Showcase(
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
        ExoPatientSection(patientId: patient.id),
        const SizedBox(height: AppSpacing.xl),
        AppText(l10n.patientSessionsTitle, variant: AppTextVariant.title),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: sessions.isEmpty
              ? Center(
                  child: AppText(
                    l10n.patientSessionsEmpty,
                    variant: AppTextVariant.body,
                    color: context.secondaryTextColor,
                  ),
                )
              : ListView.separated(
                  itemCount: sessions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    return _RecordingSessionListItem(
                      session: sessions[index],
                      onRefresh: onRefresh,
                    );
                  },
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

    return DecoratedBox(
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
                        '${l10n.recordingStatusLabel}: ${session.status.name}',
                        variant: AppTextVariant.caption,
                        color: context.secondaryTextColor,
                      ),
                    ],
                  ),
                ),
                if (hasSoap)
                  IconButton(
                    icon: Icon(
                      Icons.edit_document,
                      color: context.colorScheme.primary,
                    ),
                    tooltip: l10n.soapNoteViewAction,
                    onPressed: () {
                      SoapNoteBottomSheet.show(
                        context,
                        initialNote: session.soapNote!,
                        onSave: (updatedNote) async {
                          final repo = getIt<RecordingSessionRepository>();
                          await repo.save(
                            session.copyWith(soapNote: updatedNote),
                          );
                          onRefresh();
                        },
                      );
                    },
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
    );
  }
}
