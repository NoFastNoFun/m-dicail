import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/error/bug_report_launcher.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/core/screenshot/screenshot_detector.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/buttons/app_button.dart';
import 'package:medicail/widget/feedback/app_bottom_sheet.dart';

/// Listens for screenshots and shows a short-lived bug-report bottom sheet.
class ScreenshotBugPromptHost extends StatefulWidget {
  const ScreenshotBugPromptHost({
    super.key,
    required this.child,
    this.screenshotStream,
  });

  final Widget child;

  /// Optional override for tests.
  final Stream<void>? screenshotStream;

  @override
  State<ScreenshotBugPromptHost> createState() =>
      _ScreenshotBugPromptHostState();
}

class _ScreenshotBugPromptHostState extends State<ScreenshotBugPromptHost> {
  StreamSubscription<void>? _subscription;
  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();
    final stream = widget.screenshotStream ?? ScreenshotDetector.screenshots;
    _subscription = stream.listen((_) => _onScreenshot());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _onScreenshot() {
    if (_sheetOpen) return;
    final navContext = AppRouter.navigatorKey.currentContext;
    if (navContext == null || !navContext.mounted) return;
    _showSheet(navContext);
  }

  Future<void> _showSheet(BuildContext context) async {
    _sheetOpen = true;
    try {
      await ScreenshotBugPromptSheet.show(context);
    } finally {
      _sheetOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class ScreenshotBugPromptSheet extends StatefulWidget {
  const ScreenshotBugPromptSheet({
    super.key,
    this.autoDismiss = const Duration(seconds: 3),
    this.onReport,
  });

  final Duration autoDismiss;
  final Future<void> Function()? onReport;

  static Future<void> show(
    BuildContext context, {
    Duration autoDismiss = const Duration(seconds: 3),
    Future<void> Function()? onReport,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isDismissible: true,
      enableDrag: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      constraints: AppBottomSheet.sheetConstraints(context),
      builder: (_) => ScreenshotBugPromptSheet(
        autoDismiss: autoDismiss,
        onReport: onReport,
      ),
    );
  }

  @override
  State<ScreenshotBugPromptSheet> createState() =>
      _ScreenshotBugPromptSheetState();
}

class _ScreenshotBugPromptSheetState extends State<ScreenshotBugPromptSheet> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.autoDismiss, _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _dismiss() {
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  Future<void> _report() async {
    _timer?.cancel();
    if (widget.onReport != null) {
      await widget.onReport!();
    } else {
      final route = GoRouter.maybeOf(context)?.state.uri.toString();
      await BugReportLauncher.report(
        message: AppLocalizations.of(context).screenshotBugReportMessage,
        route: route,
      );
    }
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(l10n.screenshotBugTitle, variant: AppTextVariant.title),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            layout: AppButtonLayout.textWithIcon,
            icon: Icons.bug_report_outlined,
            label: l10n.screenshotBugReport,
            onPressed: _report,
          ),
        ],
      ),
    );
  }
}
