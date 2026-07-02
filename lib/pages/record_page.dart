import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/features/patient/domain/repositories/patient_repository.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_bloc.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_event.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_state.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_view_model.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/assign_patient_sheet.dart';
import 'package:medicail/widget/buttons/app_button.dart';
import 'package:medicail/widget/feedback/app_dialog.dart';
import 'package:medicail/widget/record/app_record_header_card.dart';
import 'package:medicail/widget/record/app_record_transcript_view.dart';

enum _RecordLeaveAction { save, discard, cancel }

class RecordPage extends StatelessWidget {
  const RecordPage({
    super.key,
    this.patientId,
  });

  final String? patientId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<VoiceCaptureBloc>()
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
  String? _patientName;
  Duration _elapsed = Duration.zero;
  DateTime? _recordingStartedAt;
  Timer? _timer;
  bool _wasListening = false;
  bool _pendingDiscardLeave = false;

  @override
  void initState() {
    super.initState();
    final patientId = widget.patientId;
    if (patientId != null && patientId.isNotEmpty) {
      _loadPatientName(patientId);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
    final hasPatient =
        widget.patientId != null && widget.patientId!.isNotEmpty;

    final action = await AppDialog.show<_RecordLeaveAction>(
      context,
      variant: AppDialogVariant.standard,
      title: l10n.recordLeaveTitle,
      body: AppText(
        hasPatient ? l10n.recordLeaveMessageWithPatient : l10n.recordLeaveMessage,
        variant: AppTextVariant.body,
      ),
      actions: [
        AppButton(
          label: l10n.recordLeaveCancel,
          style: AppButtonStyle.secondary,
          expanded: false,
          onPressed: () =>
              Navigator.of(context).pop(_RecordLeaveAction.cancel),
        ),
        AppButton(
          label: l10n.recordLeaveDiscard,
          style: AppButtonStyle.error,
          expanded: false,
          onPressed: () =>
              Navigator.of(context).pop(_RecordLeaveAction.discard),
        ),
        AppButton(
          label: hasPatient
              ? l10n.recordLeaveSave
              : l10n.recordLeaveSaveAndAssign,
          expanded: false,
          onPressed: () => Navigator.of(context).pop(_RecordLeaveAction.save),
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
      final language = Localizations.localeOf(context).languageCode;
      bloc.add(VoiceCaptureFinishConsultation(language: language));
      return;
    }

    setState(() => _pendingDiscardLeave = true);
    bloc.add(const VoiceCaptureDiscardConsultation());
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
          if (widget.patientId != null) {
            if (context.canPop()) {
              context.pop();
            }
            context.goPatientDetail(widget.patientId!);
          } else {
            AssignPatientSheet.show(context, state.sessionId);
          }
          return;
        }

        final viewModel = VoiceCaptureViewModel.fromState(state);
        _syncRecordingTimer(viewModel.isListening);
      },
      builder: (context, state) {
        final viewModel = VoiceCaptureViewModel.fromState(state);
        final theme = Theme.of(context);

        return PopScope(
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
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: theme.scaffoldBackgroundColor,
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.pagePadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppRecordHeaderCard(
                      dateLabel: dateLabel,
                      sessionTitle: _patientName,
                      elapsedLabel: _formatElapsed(_elapsed),
                      isRecording: viewModel.isListening,
                      isInitializing: viewModel.isInitializing,
                      canStart: viewModel.canStart,
                      canStop: viewModel.canStop,
                      onBack: () => _handleLeaveRequest(context),
                      onToggleRecording: () {
                      final bloc = context.read<VoiceCaptureBloc>();
                      if (viewModel.canStop) {
                        bloc.add(const VoiceCaptureStopRecording());
                        return;
                      }
                      if (viewModel.canStart) {
                        bloc.add(
                          VoiceCaptureStartRecording(
                            patientId: widget.patientId,
                          ),
                        );
                      }
                      },
                      menuItems: [
                      AppRecordMenuItem(
                        label: l10n.buttonFinishConsultation,
                        enabled: viewModel.canFinishConsultation,
                        onSelected: () {
                          final language = Localizations.localeOf(context).languageCode;
                          context.read<VoiceCaptureBloc>().add(VoiceCaptureFinishConsultation(language: language));
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
                          context
                              .read<VoiceCaptureBloc>()
                              .add(const VoiceCaptureClearTranscript());
                        },
                      ),
                      ],
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
                    child: AppRecordTranscriptView(
                      transcript: viewModel.transcript,
                      emptyHint: l10n.transcriptEmptyHint,
                    ),
                  ),
                ],
              ),
              ),
            ),
          ), // close Scaffold
          if (viewModel.isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: AppSpacing.md),
                      AppText(
                        "Génération de la note SOAP par l'IA...",
                        variant: AppTextVariant.body,
                        color: Colors.white,
                      ),
                    ],
                  ),
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
