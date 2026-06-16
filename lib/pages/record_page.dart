import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_bloc.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_event.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_state.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_view_model.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_session_status_banner.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/assign_patient_sheet.dart';
import 'package:medicail/widget/inputs/app_input.dart';
import 'package:medicail/features/tutorial/domain/tutorial_flow.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_bloc.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_state.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_step_extensions.dart';
import 'package:showcaseview/showcaseview.dart';

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

class _RecordViewState extends State<_RecordView> {
  late final TextEditingController _transcriptController;
  final GlobalKey _startRecordKey = GlobalKey();
  final GlobalKey _transcriptKey = GlobalKey();
  final GlobalKey _stopRecordKey = GlobalKey();
  final GlobalKey _finishConsultationKey = GlobalKey();
  final Set<TutorialStepId> _startedTutorialSteps = {};
  Timer? _transcriptTutorialTimer;
  bool _returnHomeAfterTutorialConsultation = false;

  @override
  void initState() {
    super.initState();
    _transcriptController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _handleTutorialState(context.read<TutorialBloc>().state);
    });
  }

  @override
  void dispose() {
    _transcriptTutorialTimer?.cancel();
    _transcriptController.dispose();
    super.dispose();
  }

  void _handleTutorialState(TutorialState state) {
    final stepId = state.tutorialStepId;
    if (stepId == null || !_recordPageSteps.contains(stepId)) return;
    if (!_startedTutorialSteps.add(stepId)) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ShowcaseView.get().startShowCase([_showcaseKeyForStep(stepId)]);
      if (_isTranscriptTutorialStep(stepId)) {
        _scheduleTranscriptTutorialCompletion();
      }
    });
  }

  static const _recordPageSteps = {
    TutorialStepId.recordFromPatient,
    TutorialStepId.recordTranscriptFromPatient,
    TutorialStepId.recordStopFromPatient,
    TutorialStepId.recordFinishFromPatient,
    TutorialStepId.quickRecordStart,
    TutorialStepId.quickRecordTranscript,
    TutorialStepId.quickRecordStop,
    TutorialStepId.quickRecordFinish,
  };

  static const _transcriptTutorialSteps = {
    TutorialStepId.recordTranscriptFromPatient,
    TutorialStepId.quickRecordTranscript,
  };

  GlobalKey _showcaseKeyForStep(TutorialStepId stepId) {
    return switch (stepId) {
      TutorialStepId.recordTranscriptFromPatient ||
      TutorialStepId.quickRecordTranscript => _transcriptKey,
      TutorialStepId.recordStopFromPatient ||
      TutorialStepId.quickRecordStop => _stopRecordKey,
      TutorialStepId.recordFinishFromPatient ||
      TutorialStepId.quickRecordFinish => _finishConsultationKey,
      _ => _startRecordKey,
    };
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
      if (stepId == null || !_isTranscriptTutorialStep(stepId)) {
        return;
      }
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

  void _startRecording() {
    final tutorialBloc = context.read<TutorialBloc>();
    if (tutorialBloc.isCurrentStep(TutorialStepId.recordFromPatient)) {
      tutorialBloc.completeStep(TutorialStepId.recordFromPatient);
    } else if (tutorialBloc.isCurrentStep(TutorialStepId.quickRecordStart)) {
      tutorialBloc.completeStep(TutorialStepId.quickRecordStart);
    }

    context.read<VoiceCaptureBloc>().add(
      VoiceCaptureStartRecording(patientId: widget.patientId),
    );
  }

  void _stopRecording() {
    final tutorialBloc = context.read<TutorialBloc>();
    if (tutorialBloc.isCurrentStep(TutorialStepId.recordStopFromPatient)) {
      tutorialBloc.completeStep(TutorialStepId.recordStopFromPatient);
    } else if (tutorialBloc.isCurrentStep(TutorialStepId.quickRecordStop)) {
      tutorialBloc.completeStep(TutorialStepId.quickRecordStop);
    }
    context.read<VoiceCaptureBloc>().add(const VoiceCaptureStopRecording());
  }

  void _finishConsultation() {
    final tutorialBloc = context.read<TutorialBloc>();
    if (tutorialBloc.isCurrentStep(TutorialStepId.recordFinishFromPatient)) {
      _returnHomeAfterTutorialConsultation = true;
      tutorialBloc.completeStep(TutorialStepId.recordFinishFromPatient);
    } else if (tutorialBloc.isCurrentStep(TutorialStepId.quickRecordFinish)) {
      tutorialBloc.completeStep(TutorialStepId.quickRecordFinish);
    }

    context.read<VoiceCaptureBloc>().add(
      const VoiceCaptureFinishConsultation(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<VoiceCaptureBloc, VoiceCaptureState>(
      listener: (context, state) {
        if (state is VoiceCaptureConsultationFinished) {
          if (_returnHomeAfterTutorialConsultation) {
            _returnHomeAfterTutorialConsultation = false;
            context.goHome();
          } else if (widget.patientId != null) {
            if (context.canPop()) {
              context.pop();
            }
          } else {
            AssignPatientSheet.show(context, state.sessionId);
          }
          return;
        }

        final transcript = VoiceCaptureViewModel.fromState(state).transcript;
        if (_transcriptController.text != transcript) {
          _transcriptController.text = transcript;
        }
      },
      builder: (context, state) {
        final viewModel = VoiceCaptureViewModel.fromState(state);

        return BlocListener<TutorialBloc, TutorialState>(
          listener: (context, tutState) {
            _handleTutorialState(tutState);
          },
          child: AppScaffold(
            title: l10n.recordTitle,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSessionStatusBanner(
                  label: viewModel.errorMessage != null
                      ? l10n.errorAudio
                      : _statusLabel(l10n, viewModel.status),
                  color: _statusColor(viewModel.status),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (viewModel.errorMessage != null) ...[
                  AppText(
                    viewModel.errorMessage!,
                    variant: AppTextVariant.body,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                Showcase(
                  key: _transcriptKey,
                  title: l10n.tutorialRecordTranscriptTitle,
                  description: l10n.tutorialRecordTranscriptDesc,
                  disposeOnTap: true,
                  onTargetClick: _completeTranscriptTutorialStep,
                  child: AppInput(
                    variant: AppInputVariant.textarea,
                    label: l10n.transcriptLabel,
                    hint: l10n.transcriptEmptyHint,
                    controller: _transcriptController,
                    readOnly: true,
                    maxLines: 12,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: Showcase(
                        key: _startRecordKey,
                        title: l10n.tutorialRecordTitle,
                        description: l10n.tutorialRecordDesc,
                        disposeOnTap: true,
                        onTargetClick: () {
                          _startRecording();
                        },
                        child: AppButton(
                          label: l10n.buttonStart,
                          onPressed: () {
                            _startRecording();
                          },
                          isLoading: viewModel.isInitializing,
                          enabled: viewModel.canStart,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Showcase(
                        key: _stopRecordKey,
                        title: l10n.tutorialRecordStopTitle,
                        description: l10n.tutorialRecordStopDesc,
                        disposeOnTap: true,
                        onTargetClick: _stopRecording,
                        child: AppButton(
                          label: l10n.buttonStop,
                          style: AppButtonStyle.secondary,
                          onPressed: _stopRecording,
                          enabled: viewModel.canStop,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Showcase(
                  key: _finishConsultationKey,
                  title: l10n.tutorialRecordFinishTitle,
                  description: l10n.tutorialRecordFinishDesc,
                  disposeOnTap: true,
                  onTargetClick: _finishConsultation,
                  child: AppButton(
                    label: l10n.buttonFinishConsultation,
                    style: AppButtonStyle.warning,
                    onPressed: _finishConsultation,
                    enabled: viewModel.canFinishConsultation,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: l10n.buttonClear,
                  style: AppButtonStyle.secondary,
                  onPressed: () => context.read<VoiceCaptureBloc>().add(
                    const VoiceCaptureClearTranscript(),
                  ),
                  enabled: viewModel.canClear,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _statusLabel(AppLocalizations l10n, VoiceCaptureSessionStatus status) {
    return switch (status) {
      VoiceCaptureSessionStatus.initializing => l10n.recordStatusInitializing,
      VoiceCaptureSessionStatus.processing => l10n.recordStatusInitializing,
      VoiceCaptureSessionStatus.listening => l10n.recordStatusListening,
      VoiceCaptureSessionStatus.paused => l10n.recordStatusPaused,
      VoiceCaptureSessionStatus.ended => l10n.recordStatusEnded,
      _ => l10n.recordStatusReady,
    };
  }

  Color _statusColor(VoiceCaptureSessionStatus status) {
    return switch (status) {
      VoiceCaptureSessionStatus.listening => AppColors.info,
      VoiceCaptureSessionStatus.paused => AppColors.textSecondary,
      VoiceCaptureSessionStatus.failure => AppColors.error,
      _ => AppColors.textSecondary,
    };
  }
}
