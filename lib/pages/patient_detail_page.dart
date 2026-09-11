import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/error/failure.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/patient/domain/entities/anamnese.dart';
import 'package:medicail/widget/consultation/new_patient_anamnese_carousel.dart';
import 'package:medicail/widget/consultation/anamnese/anamnese_summary_page.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:medicail/features/patient/presentation/detail/patient_detail_bloc.dart';
import 'package:medicail/features/patient/presentation/detail/patient_detail_event.dart';
import 'package:medicail/features/patient/presentation/detail/patient_detail_state.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/patient_creation_sheet.dart';
import 'package:medicail/widget/soap_note_bottom_sheet.dart';
import 'package:medicail/widget/transcript_view_sheet.dart';
import 'package:medicail/widget/legal/app_eu_ai_label.dart';
import 'package:medicail/widget/app_pathology_tag.dart';
import 'package:medicail/widget/feedback/app_showcase.dart';
import 'package:medicail/widget/feedback/app_dialog.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
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
  if (!context.mounted) return;
  onRefresh();
}

class PatientDetailPage extends StatelessWidget {
  const PatientDetailPage({super.key, required this.patientId, this.sessionId});

  final String patientId;
  final String? sessionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<PatientDetailBloc>()..add(PatientDetailRequested(patientId)),
      child: _PatientDetailContent(sessionId: sessionId),
    );
  }
}

class _PatientDetailContent extends StatefulWidget {
  const _PatientDetailContent({this.sessionId});

  final String? sessionId;

  @override
  State<_PatientDetailContent> createState() => _PatientDetailContentState();
}

class _PatientDetailContentState extends State<_PatientDetailContent> {
  final _consultKey = GlobalKey();
  final _startedTutorialSteps = <TutorialStepId>{};
  String? _openedSessionId;

  void _openRequestedNote(PatientDetailState state) {
    final sessionId = widget.sessionId;
    if (state is! PatientDetailLoaded ||
        state.patient == null ||
        sessionId == null ||
        _openedSessionId == sessionId) {
      return;
    }
    for (final session in state.sessions) {
      if (session.id != sessionId || session.soapNote == null) continue;
      _openedSessionId = sessionId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showSoapNote(
          context,
          session: session,
          onRefresh: () {
            if (!mounted) return;
            context.read<PatientDetailBloc>().add(
              PatientDetailRequested(state.patient!.id),
            );
          },
        );
      });
      return;
    }
  }

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

  Future<void> _archivePatient(Patient patient) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppDialog.show<bool>(
      context,
      variant: AppDialogVariant.standard,
      title: l10n.patientArchiveTitle,
      body: AppText(l10n.patientArchiveBody, variant: AppTextVariant.body),
      actionsBuilder: (dialogContext) => [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: AppText(l10n.buttonCancel, variant: AppTextVariant.label),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: AppText(
            l10n.patientArchiveConfirm,
            variant: AppTextVariant.label,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
    if (confirmed != true || !mounted) return;
    context.read<PatientDetailBloc>().add(PatientDetailArchived(patient.id));
    AppToast.showSuccess(context, l10n.patientArchiveSuccess);
  }

  Future<void> _unarchivePatient(Patient patient) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppDialog.show<bool>(
      context,
      variant: AppDialogVariant.standard,
      title: l10n.patientUnarchiveTitle,
      body: AppText(l10n.patientUnarchiveBody, variant: AppTextVariant.body),
      actionsBuilder: (dialogContext) => [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: AppText(l10n.buttonCancel, variant: AppTextVariant.label),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: AppText(
            l10n.patientUnarchiveConfirm,
            variant: AppTextVariant.label,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
    if (confirmed != true || !mounted) return;
    context.read<PatientDetailBloc>().add(PatientDetailUnarchived(patient.id));
    AppToast.showSuccess(context, l10n.patientUnarchiveSuccess);
  }

  Future<void> _deletePatient(Patient patient) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppDialog.show<bool>(
      context,
      variant: AppDialogVariant.standard,
      title: l10n.patientDeleteTitle,
      body: AppText(l10n.patientDeleteBody, variant: AppTextVariant.body),
      actionsBuilder: (dialogContext) => [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: AppText(l10n.buttonCancel, variant: AppTextVariant.label),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: AppText(
            l10n.patientDeleteConfirm,
            variant: AppTextVariant.label,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
    if (confirmed != true || !mounted) return;
    context.read<PatientDetailBloc>().add(PatientDetailDeleted(patient.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<PatientDetailBloc, PatientDetailState>(
      listener: (context, state) {
        _openRequestedNote(state);
        if (state is PatientDetailDeletedSuccess) {
          AppToast.showSuccess(context, l10n.patientDeleteSuccess);
          if (context.canPop()) {
            context.pop();
          } else {
            context.goPatients();
          }
        }
        if (state is PatientDetailFailure) {
          AppToast.showError(context, state.message);
        }
      },
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
                  PopupMenuButton<_PatientDetailAction>(
                    onSelected: (action) {
                      switch (action) {
                        case _PatientDetailAction.archive:
                          _archivePatient(patient);
                        case _PatientDetailAction.unarchive:
                          _unarchivePatient(patient);
                        case _PatientDetailAction.delete:
                          _deletePatient(patient);
                      }
                    },
                    itemBuilder: (context) => [
                      if (patient.isArchived)
                        PopupMenuItem(
                          value: _PatientDetailAction.unarchive,
                          child: Text(l10n.patientUnarchiveConfirm),
                        )
                      else
                        PopupMenuItem(
                          value: _PatientDetailAction.archive,
                          child: Text(l10n.patientArchiveConfirm),
                        ),
                      PopupMenuItem(
                        value: _PatientDetailAction.delete,
                        child: Text(
                          l10n.patientDeleteConfirm,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
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
                    showWrittenNotes: widget.sessionId != null,
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

enum _PatientDetailAction { archive, unarchive, delete }

enum _DossierTab { oral, written }

class _PatientDetailView extends StatefulWidget {
  const _PatientDetailView({
    required this.patient,
    required this.sessions,
    required this.consultKey,
    required this.onRefresh,
    this.showWrittenNotes = false,
  });

  final Patient patient;
  final List<RecordingSession> sessions;
  final GlobalKey consultKey;
  final VoidCallback onRefresh;
  final bool showWrittenNotes;

  @override
  State<_PatientDetailView> createState() => _PatientDetailViewState();
}

class _PatientDetailViewState extends State<_PatientDetailView> {
  late _DossierTab _selectedTab = widget.showWrittenNotes
      ? _DossierTab.written
      : _DossierTab.oral;

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
    final latestPathologyTags = _latestSessionPathologyTags(widget.sessions);

    return ListView(
      children: [
        AppText(patient.displayName, variant: AppTextVariant.headline),
        if (latestPathologyTags.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final tag in latestPathologyTags)
                AppPathologyTag(
                  label: tag,
                  compact: true,
                  icon: Icons.history,
                ),
            ],
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
                Icon(
                  Icons.cake_outlined,
                  size: 16,
                  color: context.secondaryTextColor,
                ),
                const SizedBox(width: AppSpacing.xs),
                AppText(
                  '${DateFormat.yMd(l10n.localeName).format(patient.birthDate!)} (${_calculateAge(patient.birthDate!)} ans)',
                  variant: AppTextVariant.caption,
                  color: context.secondaryTextColor,
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              if (patient.sex != null) ...[
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: context.secondaryTextColor,
                ),
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
        if (patient.metadata.birthPlace != null) ...[
          Row(
            children: [
              Icon(
                Icons.place_outlined,
                size: 16,
                color: context.secondaryTextColor,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: AppText(
                  patient.metadata.birthPlace!,
                  variant: AppTextVariant.caption,
                  color: context.secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        if (patient.contact?.phone != null ||
            patient.contact?.email != null) ...[
          Row(
            children: [
              if (patient.contact?.phone != null) ...[
                Icon(
                  Icons.phone_outlined,
                  size: 16,
                  color: context.secondaryTextColor,
                ),
                const SizedBox(width: AppSpacing.xs),
                AppText(
                  patient.contact!.phone!,
                  variant: AppTextVariant.caption,
                  color: context.secondaryTextColor,
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              if (patient.contact?.email != null) ...[
                Icon(
                  Icons.email_outlined,
                  size: 16,
                  color: context.secondaryTextColor,
                ),
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
              Icon(
                Icons.home_outlined,
                size: 16,
                color: context.secondaryTextColor,
              ),
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
              Icon(
                Icons.note_alt_outlined,
                size: 16,
                color: context.secondaryTextColor,
              ),
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
        _AnamneseCard(
          patient: patient,
          onRefresh: widget.onRefresh,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (!patient.isArchived)
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
        if (!patient.isArchived) const SizedBox(height: AppSpacing.xl),
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
              child: _DismissibleSessionItem(
                session: session,
                patientId: patient.id,
                child: _selectedTab == _DossierTab.oral
                    ? _OralSessionListItem(session: session)
                    : _WrittenSessionListItem(
                        session: session,
                        onRefresh: widget.onRefresh,
                      ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DismissibleSessionItem extends StatelessWidget {
  const _DismissibleSessionItem({
    required this.session,
    required this.patientId,
    required this.child,
  });

  final RecordingSession session;
  final String patientId;
  final Widget child;

  Future<bool> _confirmAndDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppDialog.show<bool>(
      context,
      variant: AppDialogVariant.standard,
      title: l10n.sessionDeleteTitle,
      body: AppText(l10n.sessionDeleteBody, variant: AppTextVariant.body),
      actionsBuilder: (dialogContext) => [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: AppText(l10n.buttonCancel, variant: AppTextVariant.label),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: AppText(
            l10n.sessionDeleteConfirm,
            variant: AppTextVariant.label,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
    if (confirmed != true || !context.mounted) return false;
    try {
      await getIt<RecordingSessionRepository>().delete(session.id);
      if (!context.mounted) return false;
      context.read<PatientDetailBloc>().add(PatientDetailRequested(patientId));
      AppToast.showSuccess(context, l10n.sessionDeleteSuccess);
      return true;
    } catch (error) {
      if (context.mounted) {
        AppToast.showError(
          context,
          Failure.fromException(error).message,
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey('session-delete-${session.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmAndDelete(context),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: AppRadius.mdBorder,
        ),
        child: Icon(
          Icons.delete_outline,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
      child: child,
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
          isAi: session.transcriptIsAi,
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
                        if (session.pathologyNames.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: [
                              for (final name in session.pathologyNames)
                                AppPathologyTag(
                                  label: name,
                                  compact: true,
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    session.transcriptIsAi
                        ? Icons.auto_awesome
                        : Icons.mic_outlined,
                    color: session.transcriptIsAi
                        ? theme.colorScheme.primary
                        : context.secondaryTextColor,
                  ),
                ],
              ),
              if (session.transcriptIsAi) ...[
                const SizedBox(height: AppSpacing.xs),
                const AppEuAiLabel(kind: EuAiLabelKind.generated),
              ],
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

void _showSoapNote(
  BuildContext context, {
  required RecordingSession session,
  required VoidCallback onRefresh,
}) {
  final note = session.soapNote;
  if (note == null) return;
  SoapNoteBottomSheet.show(
    context,
    initialNote: note,
    showTranscript: false,
    onSave: (updatedNote) async {
      await getIt<RecordingSessionRepository>().save(
        session.copyWith(soapNote: updatedNote),
      );
      if (context.mounted) onRefresh();
    },
  );
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
          : () =>
                _showSoapNote(context, session: session, onRefresh: onRefresh),
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
                        if (session.pathologyNames.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: [
                              for (final name in session.pathologyNames)
                                AppPathologyTag(
                                  label: name,
                                  compact: true,
                                ),
                            ],
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

List<String> _latestSessionPathologyTags(List<RecordingSession> sessions) {
  RecordingSession? latestWithPathology;
  for (final session in sessions) {
    if (!session.hasPathology) {
      continue;
    }
    if (latestWithPathology == null ||
        session.startedAt.isAfter(latestWithPathology.startedAt)) {
      latestWithPathology = session;
    }
  }
  return latestWithPathology?.pathologyNames ?? const [];
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

class _AnamneseCard extends StatelessWidget {
  const _AnamneseCard({
    required this.patient,
    required this.onRefresh,
  });

  final Patient patient;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final hasAnamnese = patient.metadata.anamnese.isNotEmpty;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor),
        borderRadius: AppRadius.mdBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medical_information_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppText(
                    l10n.anamneseCardTitle,
                    variant: AppTextVariant.title,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              hasAnamnese
                  ? l10n.anamneseCardFilled
                  : l10n.anamneseCardEmpty,
              variant: AppTextVariant.body,
              color: context.secondaryTextColor,
            ),
            const SizedBox(height: AppSpacing.md),
            if (hasAnamnese) ...[
              AppButton(
                onPressed: () => showAnamneseSummary(
                  context,
                  patient: patient,
                ),
                style: AppButtonStyle.secondary,
                label: l10n.anamneseCardViewSummary,
                expanded: true,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            AppButton(
              onPressed: () async {
                final result = await showAnamneseCarousel(
                  context,
                  initialPatient: patient,
                );
                if (result != null) {
                  onRefresh();
                }
              },
              style: AppButtonStyle.secondary,
              label: hasAnamnese
                  ? l10n.anamneseCardEdit
                  : l10n.anamneseCardComplete,
              expanded: true,
            ),
          ],
        ),
      ),
    );
  }
}
