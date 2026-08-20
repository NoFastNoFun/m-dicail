import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/error/last_api_error_report.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AppToastHost extends StatefulWidget {
  const AppToastHost({
    super.key,
    required this.child,
  });

  final Widget child;

  static AppToastHostState? of(BuildContext context) {
    return context.findAncestorStateOfType<AppToastHostState>();
  }

  @override
  State<AppToastHost> createState() => AppToastHostState();
}

class AppToastHostState extends State<AppToastHost> {
  OverlayEntry? _entry;
  Timer? _timer;

  void show({
    required BuildContext overlayContext,
    required String message,
    required AppToastType type,
    required Duration duration,
    String? details,
  }) {
    _dismiss();

    final overlay = Overlay.of(overlayContext);
    final reportDetails = details ??
        (type == AppToastType.error ? LastApiErrorReport.details : null);

    _entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.paddingOf(context).top + AppSpacing.lg,
        left: 0,
        right: 0,
        child: AppToastWidget(
          message: message,
          type: type,
          details: reportDetails,
          onDismiss: _dismiss,
          onCopyDetails: type == AppToastType.error
              ? () => _copyErrorDetails(context, message, reportDetails)
              : null,
          onReport: type == AppToastType.error
              ? () => _reportError(context, message, reportDetails)
              : null,
        ),
      ),
    );

    overlay.insert(_entry!);

    _timer = Timer(duration, _dismiss);
  }

  Future<void> _copyErrorDetails(
    BuildContext context,
    String message,
    String? details,
  ) async {
    final text = LastApiErrorReport.buildClipboardText(
      message: message,
      details: details,
    );
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);
    show(
      overlayContext: context,
      message: l10n.errorToastCopied,
      type: AppToastType.success,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _reportError(
    BuildContext context,
    String message,
    String? details,
  ) async {
    final text = LastApiErrorReport.buildClipboardText(
      message: message,
      details: details,
    );
    await Clipboard.setData(ClipboardData(text: text));
    await launchUrlString(
      AppToast.errorReportFormUrl,
      mode: LaunchMode.externalApplication,
    );
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);
    show(
      overlayContext: context,
      message: l10n.errorToastCopied,
      type: AppToastType.success,
      duration: const Duration(seconds: 2),
    );
  }

  void _dismiss() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
