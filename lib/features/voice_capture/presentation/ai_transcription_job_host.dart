import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/config/app_platform.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/router/app_routes.dart';
import 'package:medicail/features/voice_capture/presentation/ai_transcription_job_cubit.dart';
import 'package:medicail/features/voice_capture/presentation/ai_transcription_job_state.dart';
import 'package:medicail/widget/feedback/app_toast.dart';

/// Listens to [AiTranscriptionJobCubit] for in-app banners and notification taps.
class AiTranscriptionJobHost extends StatefulWidget {
  const AiTranscriptionJobHost({super.key, required this.child});

  final Widget child;

  @override
  State<AiTranscriptionJobHost> createState() => _AiTranscriptionJobHostState();
}

class _AiTranscriptionJobHostState extends State<AiTranscriptionJobHost> {
  bool _showingStickyBanner = false;

  @override
  void initState() {
    super.initState();
    if (!isDesktopPlatform) {
      FlutterForegroundTask.addTaskDataCallback(_onForegroundTaskData);
    }
  }

  @override
  void dispose() {
    if (!isDesktopPlatform) {
      FlutterForegroundTask.removeTaskDataCallback(_onForegroundTaskData);
    }
    super.dispose();
  }

  void _onForegroundTaskData(Object data) {
    if (data is Map && data['event'] == 'notificationTap') {
      _openRecordForActiveJob();
    }
  }

  void _openRecordForActiveJob() {
    final cubit = getIt<AiTranscriptionJobCubit>();
    final patientId = cubit.activePatientId;
    final router = getIt<GoRouter>();
    final location = router.routerDelegate.currentConfiguration.uri.toString();
    if (location.startsWith(AppRoutes.record)) {
      return;
    }
    if (patientId != null && patientId.isNotEmpty) {
      router.push(
        Uri(
          path: AppRoutes.record,
          queryParameters: {'patientId': patientId},
        ).toString(),
      );
    } else {
      router.push(AppRoutes.record);
    }
  }

  bool _isOnRecordRoute() {
    final router = getIt<GoRouter>();
    final location = router.routerDelegate.currentConfiguration.uri.toString();
    return location.startsWith(AppRoutes.record);
  }

  String _etaLabel(AppLocalizations l10n, AiTranscriptionJobRunning running) {
    final remaining = running.remainingEstimate;
    if (remaining <= Duration.zero) {
      return l10n.recordAiTranscribingEtaSoon;
    }
    if (remaining.inMinutes >= 1) {
      return l10n.recordAiTranscribingEtaMinutes(
        remaining.inMinutes + (remaining.inSeconds % 60 > 0 ? 1 : 0),
      );
    }
    return l10n.recordAiTranscribingEtaSeconds(
      remaining.inSeconds.clamp(1, 59),
    );
  }

  void _dismissStickyIfNeeded() {
    if (_showingStickyBanner && mounted) {
      AppToast.dismiss(context);
      _showingStickyBanner = false;
    }
  }

  void _showRunningBanner(
    BuildContext context,
    AiTranscriptionJobRunning running,
  ) {
    if (_isOnRecordRoute()) {
      _dismissStickyIfNeeded();
      return;
    }
    final l10n = AppLocalizations.of(context);
    final eta = _etaLabel(l10n, running);
    AppToast.show(
      context,
      message: l10n.recordAiTranscribingBannerRunning(eta),
      type: AppToastType.info,
      sticky: true,
      onTap: _openRecordForActiveJob,
    );
    _showingStickyBanner = true;
  }

  void _showReadyBanner(BuildContext context) {
    if (_isOnRecordRoute()) {
      _dismissStickyIfNeeded();
      return;
    }
    final l10n = AppLocalizations.of(context);
    AppToast.showSuccess(
      context,
      l10n.recordAiTranscribingBannerReady,
      sticky: true,
      onTap: _openRecordForActiveJob,
    );
    _showingStickyBanner = true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AiTranscriptionJobCubit, AiTranscriptionJobState>(
      listenWhen: (previous, current) => previous.runtimeType != current.runtimeType ||
          (current is AiTranscriptionJobRunning &&
              previous is AiTranscriptionJobRunning),
      listener: (context, state) {
        switch (state) {
          case AiTranscriptionJobRunning():
            _showRunningBanner(context, state);
          case AiTranscriptionJobReady():
            _showReadyBanner(context);
          case AiTranscriptionJobFailed(:final message):
            _dismissStickyIfNeeded();
            if (!_isOnRecordRoute()) {
              AppToast.showError(context, message);
            }
          case AiTranscriptionJobCompletedWithoutCompare():
          case AiTranscriptionJobIdle():
            _dismissStickyIfNeeded();
        }
      },
      child: widget.child,
    );
  }
}
