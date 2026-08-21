import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/layout/app_breakpoints.dart';
import 'package:medicail/core/layout/app_content_constraint.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/features/patient/domain/repositories/patient_repository.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:medicail/features/note_template/domain/repositories/note_template_repository.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_bloc.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_event.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_state.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_view_model.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/assign_patient_sheet.dart';
import 'package:medicail/widget/buttons/app_button.dart';
import 'package:medicail/widget/feedback/app_dialog.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/widget/record/app_record_header_card.dart';
import 'package:medicail/widget/record/app_record_transcript_view.dart';
import 'package:medicail/widget/templates/template_picker_sheet.dart';
import 'package:medicail/widget/feedback/app_showcase.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:medicail/features/tutorial/domain/tutorial_flow.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_bloc.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_state.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_step_extensions.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_showcase_launcher.dart';
import 'package:medicail/widget/record/app_record_processing_overlay.dart';

enum _RecordLeaveAction { save, discard, cancel }

class RecordPage extends StatelessWidget {
  const RecordPage({super.key, this.patientId});

  final String? patientId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<VoiceCaptureBloc>()
            ..add(const VoiceCaptureInitializeRequested()),
      child: _RecordView(patientId: patientId),
    );
  }
}

class _RecordView extends StatefulWidget {
  const _RecordView({this.patientId});

  final String? patientId;

  @override
  State<_RecordView> createState() => _RecordViewState();
}

class _RecordViewState extends State<_RecordView> with WidgetsBindingObserver {
  String? _patientName;
  Duration _elapsed = Duration.zero;
  DateTime? _recordingStartedAt;
  Timer? _timer;
  bool _wasListening = false;
  bool _pendingDiscardLeave = false;
  final _startedTutorialSteps = <TutorialStepId>{};
  final _recordToggleKey = GlobalKey();
  final _transcriptKey = GlobalKey();
  final _menuKey = GlobalKey();
  final _menuButtonKey = GlobalKey<PopupMenuButtonState<int>>();
  bool _returnHomeAfterTutorialConsultation = false;
  Timer? _transcriptTutorialTimer;
  Timer? _debounceTimer;
  String _lastTranscript = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final patientId = widget.patientId;
    if (patientId != null && patientId.isNotEmpty) {
      _loadPatientName(patientId);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _skipDuplicateQuickRecordTutorialIfNeeded();
      if (!mounted) return;
      _handleTutorialState(context.read<TutorialBloc>().state);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _transcriptTutorialTimer?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) {
      return;
    }
    final bloc = context.read<VoiceCaptureBloc>();
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        bloc.add(const VoiceCaptureAppBackgrounded());
      case AppLifecycleState.resumed:
        bloc.add(const VoiceCaptureAppForegrounded());
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _loadPatientName(String patientId) async {
    final patient = await getIt<PatientRepository>().getById(patientId);
    if (!mounted || patient == null) {
      return;
    }
    setState(() => _patientName = patient.displayName);
  }

  void _syncRecordingTimer(bool isListening) {
    if (isListening && !_wasListening) {
      _recordingStartedAt = DateTime.now().subtract(_elapsed);
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        final startedAt = _recordingStartedAt;
        if (startedAt == null || !mounted) {
          return;
        }
        setState(() {
          _elapsed = DateTime.now().difference(startedAt);
        });
      });
    } else if (!isListening && _wasListening) {
      _timer?.cancel();
      _timer = null;
      final startedAt = _recordingStartedAt;
      if (startedAt != null) {
        _elapsed = DateTime.now().difference(startedAt);
      }
      _recordingStartedAt = null;
    }
    _wasListening = isListening;
  }

  String _formatElapsed(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _skipDuplicateQuickRecordTutorialIfNeeded() async {
    final hasPatient = widget.patientId != null && widget.patientId!.isNotEmpty;
    if (hasPatient) return;

    final tutorialBloc = context.read<TutorialBloc>();
    if (!tutorialBloc.state.isAnyTutorialStep(
      TutorialFlow.quickRecordPageDuplicateSteps,
    )) {
      return;
    }
    await tutorialBloc.skipQuickRecordPageTutorialSteps();
  }

  void _handleTutorialState(TutorialState state) {
    final stepId = state.tutorialStepId;
    if (stepId == null || !_recordPageSteps.contains(stepId)) return;
    if (_startedTutorialSteps.contains(stepId)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (widget.patientId == null &&
          TutorialFlow.isQuickRecordPageDuplicate(stepId)) {
        await _skipDuplicateQuickRecordTutorialIfNeeded();
        return;
      }
      final started = await TutorialShowcaseLauncher.startWhenReady(
        context: context,
        key: _showcaseKeyForStep(stepId),
      );
      if (started && mounted) {
        _startedTutorialSteps.add(stepId);
        if (_isTranscriptTutorialStep(stepId)) {
          _scheduleTranscriptTutorialCompletion();
        }
      }
    });
  }

  static const _recordPageSteps = {
    TutorialStepId.recordFromPatient,
    TutorialStepId.recordTranscriptFromPatient,
    TutorialStepId.recordStopFromPatient,
    TutorialStepId.recordFinishFromPatient,
  };

  static const _transcriptTutorialSteps = {
    TutorialStepId.recordTranscriptFromPatient,
  };

  GlobalKey _showcaseKeyForStep(TutorialStepId stepId) {
    if (_isTranscriptTutorialStep(stepId)) {
      return _transcriptKey;
    }
    if (stepId == TutorialStepId.recordFinishFromPatient) {
      return _menuKey;
    }
    return _recordToggleKey;
  }

  bool _isTranscriptTutorialStep(TutorialStepId stepId) {
    return _transcriptTutorialSteps.contains(stepId);
  }

  void _scheduleTranscriptTutorialCompletion() {
    _transcriptTutorialTimer?.cancel();
    _transcriptTutorialTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      final tutorialBloc = context.read<TutorialBloc>();
      final stepId = tutorialBloc.state.tutorialStepId;
      if (stepId == null || !_isTranscriptTutorialStep(stepId)) return;
      ShowcaseView.get().dismiss();
      tutorialBloc.completeStep(stepId);
    });
  }

  void _completeTranscriptTutorialStep() {
    _transcriptTutorialTimer?.cancel();
    final tutorialBloc = context.read<TutorialBloc>();
    final stepId = tutorialBloc.state.tutorialStepId;
    if (stepId == null || !_isTranscriptTutorialStep(stepId)) return;
    tutorialBloc.completeStep(stepId);
  }

  Future<void> _discardTutorialSession(String sessionId) async {
    if (sessionId.isEmpty) return;
    await getIt<RecordingSessionRepository>().delete(sessionId);
  }

  void _handleConsultationFinished(VoiceCaptureConsultationFinished state) {
    final tutorialBloc = context.read<TutorialBloc>();
    final isTutorial = tutorialBloc.state is TutorialInProgress;
    final isDemoPatient = widget.patientId == TutorialFlow.demoPatientId;

    if (isTutorial && isDemoPatient) {
      unawaited(_discardTutorialSession(state.sessionId));
    }

    if (_returnHomeAfterTutorialConsultation) {
      _returnHomeAfterTutorialConsultation = false;
      context.goHome();
    } else if (widget.patientId != null) {
      final isDemoTutorialReturn = isDemoPatient && isTutorial;
      if (isDemoTutorialReturn) {
        context.goHome();
      } else {
        if (context.canPop()) {
          context.pop();
        }
        context.goPatientDetail(widget.patientId!);
      }
    } else {
      AssignPatientSheet.show(context, state.sessionId);
    }
  }

  void _startRecording() {
    final l10n = AppLocalizations.of(context);
    final tutorialBloc = context.read<TutorialBloc>();
    if (tutorialBloc.isCurrentStep(TutorialStepId.recordFromPatient)) {
      tutorialBloc.completeStep(TutorialStepId.recordFromPatient);
    }
    context.read<VoiceCaptureBloc>().add(
      VoiceCaptureStartRecording(
        patientId: widget.patientId,
        wordPeriod: l10n.punctuationWordPeriod,
        wordComma: l10n.punctuationWordComma,
        transitions: l10n.punctuationTransitions.split(','),
      ),
    );
  }

  void _stopRecording() {
    final tutorialBloc = context.read<TutorialBloc>();
    if (tutorialBloc.isCurrentStep(TutorialStepId.recordStopFromPatient)) {
      tutorialBloc.completeStep(TutorialStepId.recordStopFromPatient);
    }
    context.read<VoiceCaptureBloc>().add(const VoiceCaptureStopRecording());
  }

  Future<void> _finishConsultation() async {
    final tutorialBloc = context.read<TutorialBloc>();
    if (tutorialBloc.isCurrentStep(TutorialStepId.recordFinishFromPatient)) {
      _returnHomeAfterTutorialConsultation = true;
      tutorialBloc.completeStep(TutorialStepId.recordFinishFromPatient);
    }

    final viewModel = VoiceCaptureViewModel.fromState(
      context.read<VoiceCaptureBloc>().state,
    );
    if (viewModel.selectedTemplate == null) {
      await _pickTemplate(context);
      if (!mounted) {
        return;
      }
    }

    final language = Localizations.localeOf(context).languageCode;
    context.read<VoiceCaptureBloc>().add(
      VoiceCaptureFinishConsultation(language: language),
    );
  }

  String _currentShowcaseTitle(AppLocalizations l10n) {
    final tutorialBloc = context.read<TutorialBloc>();
    final stepId = tutorialBloc.state.tutorialStepId;
    if (stepId == TutorialStepId.recordStopFromPatient) {
      return l10n.tutorialRecordStopTitle;
    }
    if (stepId == TutorialStepId.recordFinishFromPatient) {
      return l10n.tutorialRecordFinishTitle;
    }
    return l10n.tutorialRecordTitle;
  }

  String _currentShowcaseDescription(AppLocalizations l10n) {
    final tutorialBloc = context.read<TutorialBloc>();
    final stepId = tutorialBloc.state.tutorialStepId;
    if (stepId == TutorialStepId.recordStopFromPatient) {
      return l10n.tutorialRecordStopDesc;
    }
    if (stepId == TutorialStepId.recordFinishFromPatient) {
      return l10n.tutorialRecordFinishDesc;
    }
    return l10n.tutorialRecordDesc;
  }

  void _handleShowcaseTap() {
    final tutorialBloc = context.read<TutorialBloc>();
    final stepId = tutorialBloc.state.tutorialStepId;
    if (stepId == TutorialStepId.recordStopFromPatient) {
      _stopRecording();
    } else if (stepId == TutorialStepId.recordFinishFromPatient) {
      _finishConsultation();
    } else {
      _startRecording();
    }
  }

  Future<void> _handleLeaveRequest(BuildContext context) async {
    final viewModel = VoiceCaptureViewModel.fromState(
      context.read<VoiceCaptureBloc>().state,
    );
    if (!viewModel.hasUnsavedWork) {
      if (context.canPop()) {
        context.pop();
      }
      return;
    }

    await _confirmLeave(context);
  }

  Future<void> _confirmLeave(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final hasPatient = widget.patientId != null && widget.patientId!.isNotEmpty;

    final action = await AppDialog.show<_RecordLeaveAction>(
      context,
      variant: AppDialogVariant.standard,
      title: l10n.recordLeaveTitle,
      body: AppText(
        hasPatient
            ? l10n.recordLeaveMessageWithPatient
            : l10n.recordLeaveMessage,
        variant: AppTextVariant.body,
      ),
      actionsBuilder: (dialogContext) => [
        AppButton(
          label: l10n.recordLeaveCancel,
          style: AppButtonStyle.secondary,
          expanded: false,
          onPressed: () =>
              Navigator.of(dialogContext).pop(_RecordLeaveAction.cancel),
        ),
        AppButton(
          label: l10n.recordLeaveDiscard,
          style: AppButtonStyle.error,
          expanded: false,
          onPressed: () =>
              Navigator.of(dialogContext).pop(_RecordLeaveAction.discard),
        ),
        AppButton(
          label: hasPatient ? l10n.buttonSave : l10n.recordLeaveSaveAndAssign,
          expanded: false,
          onPressed: () =>
              Navigator.of(dialogContext).pop(_RecordLeaveAction.save),
        ),
      ],
    );

    if (!context.mounted ||
        action == null ||
        action == _RecordLeaveAction.cancel) {
      return;
    }

    final bloc = context.read<VoiceCaptureBloc>();
    if (action == _RecordLeaveAction.save) {
      bloc.add(const VoiceCaptureFinishConsultation());
      return;
    }

    setState(() => _pendingDiscardLeave = true);
    bloc.add(const VoiceCaptureDiscardConsultation());
  }

  Future<NoteTemplate?> _pickTemplate(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final templates = await getIt<NoteTemplateRepository>().getAll();
    if (!context.mounted) {
      return null;
    }

    final currentState = context.read<VoiceCaptureBloc>().state;
    final selectedTemplate = switch (currentState) {
      VoiceCaptureReady(:final selectedTemplate) => selectedTemplate,
      RecordingInProgress(:final selectedTemplate) => selectedTemplate,
      ListeningPaused(:final selectedTemplate) => selectedTemplate,
      VoiceCaptureTranscribingBackground(:final selectedTemplate) =>
        selectedTemplate,
      VoiceCaptureFailure(:final selectedTemplate) => selectedTemplate,
      _ => null,
    };

    // Wait until the popup menu (if any) has fully closed.
    await Future<void>.delayed(Duration.zero);
    if (!context.mounted) {
      return null;
    }

    final template = await TemplatePickerSheet.show(
      context,
      templates: templates,
      selectedTemplateId: selectedTemplate?.id,
    );
    if (!context.mounted || template == null) {
      return null;
    }

    context.read<VoiceCaptureBloc>().add(
      VoiceCaptureTemplateSelected(template),
    );
    AppToast.showSuccess(context, l10n.templateActiveLabel(template.name));
    return template;
  }

  void _schedulePickTemplate(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(_pickTemplate(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = DateFormat('EEE, MMM d', locale).format(DateTime.now());

    return BlocConsumer<VoiceCaptureBloc, VoiceCaptureState>(
      listener: (context, state) {
        if (_pendingDiscardLeave && state is VoiceCaptureReady) {
          _pendingDiscardLeave = false;
          if (context.canPop()) {
            context.pop();
          }
          return;
        }

        if (state is VoiceCaptureConsultationFinished) {
          _handleConsultationFinished(state);
          return;
        }

        final viewModel = VoiceCaptureViewModel.fromState(state);
        _syncRecordingTimer(
          viewModel.isListening || viewModel.isTranscribingBackground,
        );

        final transcript = viewModel.transcript.trim();
        if (transcript.isNotEmpty) {
          if (transcript != _lastTranscript) {
            _lastTranscript = transcript;
            _transcriptTutorialTimer?.cancel();
            _debounceTimer?.cancel();
            _debounceTimer = Timer(const Duration(seconds: 2), () {
              if (!mounted) return;
              _completeTranscriptTutorialStep();
            });
          }
        }
      },
      builder: (context, state) {
        final viewModel = VoiceCaptureViewModel.fromState(state);
        final theme = Theme.of(context);

        return Stack(
          children: [
            PopScope(
              canPop: !viewModel.hasUnsavedWork && !viewModel.isProcessing,
              onPopInvokedWithResult: (didPop, _) {
                if (didPop) {
                  return;
                }
                if (viewModel.isProcessing) {
                  return;
                }
                _handleLeaveRequest(context);
              },
              child: Scaffold(
                backgroundColor: theme.scaffoldBackgroundColor,
                body: SafeArea(
                  child: BlocListener<TutorialBloc, TutorialState>(
                    listener: (context, state) => _handleTutorialState(state),
                    child: AppContentConstraint(
                      maxWidth: AppBreakpoints.wideContentMaxWidth,
                      applyPagePadding: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          BlocBuilder<TutorialBloc, TutorialState>(
                            builder: (context, tutorialState) {
                              final isTutorial =
                                  tutorialState is TutorialInProgress;
                              return AppShowcase(
                                key: _recordToggleKey,
                                title: _currentShowcaseTitle(l10n),
                                description: _currentShowcaseDescription(l10n),
                                disposeOnTap: false,
                                disableBarrierInteraction: true,
                                onTargetClick: _handleShowcaseTap,
                                child: AppRecordHeaderCard(
                                  cardBorderRadius: isTutorial
                                      ? AppRadius.onboardingMdBorder
                                      : AppRadius.mdBorder,
                                  controlBorderRadius: isTutorial
                                      ? AppRadius.onboardingSmBorder
                                      : AppRadius.pillBorder,
                                  dateLabel: dateLabel,
                                  sessionTitle: _patientName,
                                  templateLabel:
                                      viewModel.selectedTemplate == null
                                      ? l10n.templateNoneLabel
                                      : l10n.templateActiveLabel(
                                          viewModel.selectedTemplate!.name,
                                        ),
                                  onTemplateTap:
                                      !viewModel.isListening &&
                                          !viewModel.isProcessing
                                      ? () => _pickTemplate(context)
                                      : null,
                                  elapsedLabel: _formatElapsed(_elapsed),
                                  isRecording: viewModel.isListening,
                                  isInitializing: viewModel.isInitializing,
                                  canStart: viewModel.canStart,
                                  canStop: viewModel.canStop,
                                  onBack: () => _handleLeaveRequest(context),
                                  onToggleRecording: () {
                                    if (viewModel.canStop) {
                                      _stopRecording();
                                      return;
                                    }
                                    if (viewModel.canStart) {
                                      _startRecording();
                                    }
                                  },
                                  menuItems: [
                                    AppRecordMenuItem(
                                      label: l10n.templatePickerAction,
                                      enabled: !viewModel.isListening &&
                                          !viewModel.isProcessing,
                                      onSelected: () =>
                                          _schedulePickTemplate(context),
                                    ),
                                    AppRecordMenuItem(
                                      label: l10n.buttonFinishConsultation,
                                      enabled: viewModel.canFinishConsultation,
                                      onSelected: () {
                                        unawaited(_finishConsultation());
                                      },
                                    ),
                                    AppRecordMenuItem(
                                      label: l10n.buttonClear,
                                      enabled: viewModel.canClear,
                                      onSelected: () {
                                        setState(() {
                                          _elapsed = Duration.zero;
                                          _recordingStartedAt = null;
                                        });
                                        context.read<VoiceCaptureBloc>().add(
                                          const VoiceCaptureClearTranscript(),
                                        );
                                      },
                                    ),
                                  ],
                                  menuKey: _menuKey,
                                  menuButtonKey: _menuButtonKey,
                                  menuShowcaseTitle: _currentShowcaseTitle(
                                    l10n,
                                  ),
                                  menuShowcaseDescription:
                                      _currentShowcaseDescription(l10n),
                                  onMenuShowcaseTargetClick: () {
                                    _menuButtonKey.currentState
                                        ?.showButtonMenu();
                                    ShowcaseView.get().dismiss();
                                  },
                                ),
                              );
                            },
                          ),
                          if (viewModel.errorMessage != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            AppText(
                              viewModel.errorMessage!,
                              variant: AppTextVariant.body,
                              color: AppColors.error,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          Expanded(
                            child: AppShowcase(
                              key: _transcriptKey,
                              title: l10n.tutorialRecordTranscriptTitle,
                              description: l10n.tutorialRecordTranscriptDesc,
                              disposeOnTap: false,
                              disableBarrierInteraction: true,
                              onTargetClick: () {
                                final tutorialBloc = context
                                    .read<TutorialBloc>();
                                final stepId =
                                    tutorialBloc.state.tutorialStepId;
                                if (stepId != null) {
                                  tutorialBloc.completeStep(stepId);
                                }
                              },
                              child: AppRecordTranscriptView(
                                transcript: viewModel.transcript,
                                emptyHint: l10n.transcriptEmptyHint,
                              ),
                            ),
                          ),
                          if (viewModel.canFinishConsultation) ...[
                            const SizedBox(height: AppSpacing.lg),
                            AppButton(
                              label: l10n.buttonFinishConsultation,
                              onPressed: _finishConsultation,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (viewModel.isProcessing)
              Positioned.fill(
                child: AppRecordProcessingOverlay(
                  isTranscribingBackground: viewModel.isTranscribingBackground,
                  isEnhancing: viewModel.isEnhancing,
                ),
              ),
          ],
        );
      },
    );
  }
}
