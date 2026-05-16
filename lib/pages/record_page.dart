import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_bloc.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_event.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_state.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text_field.dart';

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
        final transcript = switch (state) {
          VoiceCaptureReady(:final transcript) => transcript,
          RecordingInProgress(:final transcript) => transcript,
          VoiceCaptureFailure() => _transcriptController.text,
          _ => null,
        };
        if (transcript != null && _transcriptController.text != transcript) {
          _transcriptController.text = transcript;
        }
      },
      builder: (context, state) {
        final isRecording = state is RecordingInProgress;
        final isLoading = state is VoiceCaptureInitial;
        final errorMessage =
            state is VoiceCaptureFailure ? state.message : null;

        return AppScaffold(
          title: l10n.recordTitle,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (errorMessage != null) ...[
                Text(
                  errorMessage,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 12),
              ],
              AppTextField(
                label: l10n.transcriptLabel,
                controller: _transcriptController,
                readOnly: true,
                maxLines: 8,
              ),
              const SizedBox(height: 16),
              AppButton(
                label: isRecording ? l10n.buttonStop : l10n.buttonStart,
                onPressed: isLoading
                    ? null
                    : () {
                        if (isRecording) {
                          context
                              .read<VoiceCaptureBloc>()
                              .add(const VoiceCaptureStopRecording());
                        } else {
                          context
                              .read<VoiceCaptureBloc>()
                              .add(const VoiceCaptureStartRecording());
                        }
                      },
                isLoading: isLoading,
              ),
            ],
          ),
        );
      },
    );
  }
}
