import 'package:flutter/services.dart';
import 'package:medicail/core/error/last_api_error_report.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:url_launcher/url_launcher_string.dart';

typedef BugReportUrlLauncher = Future<bool> Function(
  String url, {
  LaunchMode mode,
});

/// Copies report text to the clipboard and opens the shared bug-report form.
class BugReportLauncher {
  BugReportLauncher._();

  static BugReportUrlLauncher _launchUrl = launchUrlString;

  /// Test seam: replace [launchUrlString] without changing production call sites.
  static void debugSetLaunchUrl(BugReportUrlLauncher? launcher) {
    _launchUrl = launcher ?? launchUrlString;
  }

  static Future<void> report({
    required String message,
    String? details,
    String? route,
  }) async {
    final buffer = StringBuffer();
    if (route != null && route.isNotEmpty) {
      buffer.writeln('Route: $route');
    }
    final apiDetails = details ?? LastApiErrorReport.details;
    if (apiDetails != null && apiDetails.trim().isNotEmpty) {
      buffer.writeln(apiDetails.trim());
    }

    final text = LastApiErrorReport.buildClipboardText(
      message: message,
      details: buffer.isEmpty ? null : buffer.toString().trimRight(),
    );

    await Clipboard.setData(ClipboardData(text: text));
    await _launchUrl(
      AppToast.errorReportFormUrl,
      mode: LaunchMode.externalApplication,
    );
  }
}
