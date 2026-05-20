import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_bloc.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_event.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_state.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_view_model.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_session_status_banner.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/inputs/app_input.dart';

class RecordPage extends StatelessWidget {
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<VoiceCaptureBloc>()
        ..add(const VoiceCaptureInitializeRequested()),
      child: const _RecordView(),
    );
  }
}

class _RecordView extends StatefulWidget {
  const _RecordView();

  @override
  State<_RecordView> createState() => _RecordViewState();
}

class _RecordViewState extends State<_RecordView> {
  late final TextEditingController _transcriptController;

  @override
  void initState() {
    super.initState();
    _transcriptController = TextEditingController();
  }

  @override
  void dispose() {
    _transcriptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<VoiceCaptureBloc, VoiceCaptureState>(
      listener: (context, state) {
        final transcript = VoiceCaptureViewModel.fromState(state).transcript;
        if (_transcriptController.text != transcript) {
          _transcriptController.text = transcript;
        }
      },
      builder: (context, state) {
        final viewModel = VoiceCaptureViewModel.fromState(state);

        return AppScaffold(
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
              AppInput(
                variant: AppInputVariant.textarea,
                label: l10n.transcriptLabel,
                hint: l10n.transcriptEmptyHint,
                controller: _transcriptController,
                readOnly: true,
                maxLines: 12,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: l10n.buttonStart,
                      onPressed: () => context
                          .read<VoiceCaptureBloc>()
                          .add(const VoiceCaptureStartRecording()),
                      isLoading: viewModel.isInitializing,
                      enabled: viewModel.canStart,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: l10n.buttonStop,
                      style: AppButtonStyle.warning,
                      onPressed: () => context
                          .read<VoiceCaptureBloc>()
                          .add(const VoiceCaptureStopRecording()),
                      enabled: viewModel.canStop,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.buttonClear,
                style: AppButtonStyle.secondary,
                onPressed: () => context
                    .read<VoiceCaptureBloc>()
                    .add(const VoiceCaptureClearTranscript()),
                enabled: viewModel.canClear,
              ),
            ],
          ),
        );
      },
    );
  }

  String _statusLabel(
    AppLocalizations l10n,
    VoiceCaptureSessionStatus status,
  ) {
    return switch (status) {
      VoiceCaptureSessionStatus.initializing => l10n.recordStatusInitializing,
      VoiceCaptureSessionStatus.listening => l10n.recordStatusListening,
      VoiceCaptureSessionStatus.ended => l10n.recordStatusEnded,
      _ => l10n.recordStatusReady,
    };
  }

  Color _statusColor(VoiceCaptureSessionStatus status) {
    return switch (status) {
      VoiceCaptureSessionStatus.listening => AppColors.info,
      VoiceCaptureSessionStatus.failure => AppColors.error,
      _ => AppColors.textSecondary,
    };
  }
}
