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
import 'package:medicail/widget/transcript_view_sheet.dart';
import 'package:medicail/widget/app_pathology_tag.dart';
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

enum _DossierTab { oral, written }

class _PatientDetailView extends StatefulWidget {
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
  State<_PatientDetailView> createState() => _PatientDetailViewState();
}

class _PatientDetailViewState extends State<_PatientDetailView> {
  _DossierTab _selectedTab = _DossierTab.oral;

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  List<RecordingSession> get _oralSessions {
    return widget.sessions
        .where((session) => session.transcript.trim().isNotEmpty)
        .toList();
  }

  List<RecordingSession> get _writtenSessions {
    return widget.sessions
        .where((session) => session.soapNote != null)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final patient = widget.patient;
    final displayedSessions = _selectedTab == _DossierTab.oral
        ? _oralSessions
        : _writtenSessions;
    final emptyLabel = _selectedTab == _DossierTab.oral
        ? l10n.patientDossierOralEmpty
        : l10n.patientDossierWrittenEmpty;
    final latestPathologyTag = _latestSessionPathologyTag(widget.sessions);

    return ListView(
      children: [
        AppText(patient.displayName, variant: AppTextVariant.headline),
        if (latestPathologyTag != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: AppPathologyTag(
              label: latestPathologyTag,
              compact: true,
            ),
          ),
        ],
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
          key: widget.consultKey,
          title: l10n.tutorialDetailConsultTitle,
          description: l10n.tutorialDetailConsultDesc,
          disposeOnTap: false,
          disableBarrierInteraction: true,
          onTargetClick: () => _openConsultationRecord(
            context,
            patientId: patient.id,
            onRefresh: widget.onRefresh,
          ),
          child: AppButton(
            label: l10n.patientNewConsultationButton,
            onPressed: () => _openConsultationRecord(
              context,
              patientId: patient.id,
              onRefresh: widget.onRefresh,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppText(l10n.patientSessionsTitle, variant: AppTextVariant.title),
        const SizedBox(height: AppSpacing.sm),
        _DossierTabSelector(
          selectedTab: _selectedTab,
          oralLabel: l10n.patientDossierOralTab,
          writtenLabel: l10n.patientDossierWrittenTab,
          onChanged: (tab) => setState(() => _selectedTab = tab),
        ),
        const SizedBox(height: AppSpacing.md),
        if (displayedSessions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: AppText(
                emptyLabel,
                variant: AppTextVariant.body,
                color: context.secondaryTextColor,
              ),
            ),
          )
        else
          ...displayedSessions.map(
            (session) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _selectedTab == _DossierTab.oral
                  ? _OralSessionListItem(
                      session: session,
                    )
                  : _WrittenSessionListItem(
                      session: session,
                      onRefresh: widget.onRefresh,
                    ),
            ),
          ),
      ],
    );
  }
}

class _OralSessionListItem extends StatelessWidget {
  const _OralSessionListItem({required this.session});

  final RecordingSession session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final statusLabel = _statusLabel(l10n, session.status);

    return InkWell(
      onTap: () {
        TranscriptViewSheet.show(
          context,
          transcript: session.transcript,
          recordedAt: session.startedAt,
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
                        if (session.templateName != null &&
                            session.templateName!.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          AppPathologyTag(
                            label: session.templateName!,
                            compact: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.mic_outlined,
                    color: context.secondaryTextColor,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppText(
                session.transcript,
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

class _WrittenSessionListItem extends StatelessWidget {
  const _WrittenSessionListItem({
    required this.session,
    required this.onRefresh,
  });

  final RecordingSession session;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final soapNote = session.soapNote;
    final statusLabel = _statusLabel(l10n, session.status);
    final preview = _soapPreview(soapNote);

    return InkWell(
      onTap: soapNote == null
          ? null
          : () {
              SoapNoteBottomSheet.show(
                context,
                initialNote: soapNote,
                showTranscript: false,
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
                        if (session.templateName != null &&
                            session.templateName!.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          AppPathologyTag(
                            label: session.templateName!,
                            compact: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (soapNote != null)
                    Icon(
                      Icons.chevron_right,
                      color: context.secondaryTextColor,
                    ),
                ],
              ),
              if (preview.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                AppText(
                  preview,
                  variant: AppTextVariant.body,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _statusLabel(AppLocalizations l10n, RecordingSessionStatus status) {
  return switch (status) {
    RecordingSessionStatus.draft => l10n.sessionStatusDraft,
    RecordingSessionStatus.recording => l10n.sessionStatusRecording,
    RecordingSessionStatus.completed => l10n.sessionStatusCompleted,
    RecordingSessionStatus.failed => l10n.sessionStatusFailed,
  };
}

String _soapPreview(SoapNote? note) {
  if (note == null) {
    return '';
  }
  for (final section in [
    note.subjective,
    note.objective,
    note.assessment,
    note.plan,
  ]) {
    final trimmed = section.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  return '';
}

String? _latestSessionPathologyTag(List<RecordingSession> sessions) {
  if (sessions.isEmpty) {
    return null;
  }

  final latest = sessions.fold<RecordingSession>(
    sessions.first,
    (current, candidate) =>
        candidate.startedAt.isAfter(current.startedAt) ? candidate : current,
  );
  final name = latest.templateName?.trim();
  if (name == null || name.isEmpty) {
    return null;
  }
  return name;
}

class _DossierTabSelector extends StatelessWidget {
  const _DossierTabSelector({
    required this.selectedTab,
    required this.oralLabel,
    required this.writtenLabel,
    required this.onChanged,
  });

  final _DossierTab selectedTab;
  final String oralLabel;
  final String writtenLabel;
  final ValueChanged<_DossierTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: _DossierTabButton(
              label: oralLabel,
              isSelected: selectedTab == _DossierTab.oral,
              onTap: () => onChanged(_DossierTab.oral),
            ),
          ),
          Expanded(
            child: _DossierTabButton(
              label: writtenLabel,
              isSelected: selectedTab == _DossierTab.written,
              onTap: () => onChanged(_DossierTab.written),
            ),
          ),
        ],
      ),
    );
  }
}

class _DossierTabButton extends StatelessWidget {
  const _DossierTabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected
          ? theme.colorScheme.primary.withValues(alpha: 0.12)
          : Colors.transparent,
      borderRadius: AppRadius.mdBorder,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: AppText(
            label,
            variant: AppTextVariant.label,
            textAlign: TextAlign.center,
            color: isSelected
                ? theme.colorScheme.primary
                : context.secondaryTextColor,
          ),
        ),
      ),
    );
  }
}
