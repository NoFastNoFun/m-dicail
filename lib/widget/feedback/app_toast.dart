import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/error/last_api_error_report.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_toast_host.dart';

enum AppToastType { success, warning, error, info }

class AppToast {
  AppToast._();

  static const String errorReportFormUrl =
      'https://forms.gle/q37qQwNVhezKx1mLA';

  static void show(
    BuildContext context, {
    required String message,
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 3),
    String? details,
    VoidCallback? onTap,
    bool sticky = false,
  }) {
    AppToastHost.of(context)?.show(
      overlayContext: context,
      message: message,
      type: type,
      duration: duration,
      details: details,
      onTap: onTap,
      sticky: sticky,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 6),
    String? details,
  }) {
    show(
      context,
      message: message,
      type: AppToastType.error,
      duration: duration,
      details: details ?? LastApiErrorReport.details,
    );
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    bool sticky = false,
  }) {
    show(
      context,
      message: message,
      type: AppToastType.success,
      duration: duration,
      onTap: onTap,
      sticky: sticky,
    );
  }

  static void dismiss(BuildContext context) {
    AppToastHost.of(context)?.dismiss();
  }
}

class AppToastWidget extends StatefulWidget {
  const AppToastWidget({
    super.key,
    required this.message,
    required this.type,
    required this.onDismiss,
    this.details,
    this.onCopyDetails,
    this.onReport,
    this.onTap,
  });

  final String message;
  final AppToastType type;
  final VoidCallback onDismiss;
  final String? details;
  final VoidCallback? onCopyDetails;
  final VoidCallback? onReport;
  final VoidCallback? onTap;

  @override
  State<AppToastWidget> createState() => _AppToastWidgetState();
}

class _AppToastWidgetState extends State<AppToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final (accent, icon) = switch (widget.type) {
      AppToastType.success => (AppColors.success, Icons.check_circle_outline),
      AppToastType.warning => (AppColors.warning, Icons.warning_amber_outlined),
      AppToastType.error => (AppColors.error, Icons.error_outline),
      AppToastType.info => (AppColors.info, Icons.info_outline),
    };

    final messageArea = Row(
      children: [
        Container(
          width: 4,
          height: 32,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Icon(icon, color: accent, size: 22),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: AppText(widget.message, variant: AppTextVariant.body),
        ),
      ],
    );

    Widget content = messageArea;
    if (widget.onTap != null) {
      content = InkWell(
        onTap: () {
          widget.onTap!();
          widget.onDismiss();
        },
        borderRadius: AppRadius.mdBorder,
        child: messageArea,
      );
    } else if (widget.onCopyDetails != null) {
      content = InkWell(
        onTap: widget.onCopyDetails,
        borderRadius: AppRadius.mdBorder,
        child: messageArea,
      );
    }

    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: AppRadius.mdBorder,
              border: Border.all(color: theme.dividerColor),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(child: content),
                if (widget.onReport != null)
                  IconButton(
                    icon: const Icon(Icons.bug_report_outlined, size: 20),
                    color: context.secondaryTextColor,
                    tooltip: l10n.errorToastReport,
                    onPressed: widget.onReport,
                    visualDensity: VisualDensity.compact,
                  ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  color: context.secondaryTextColor,
                  onPressed: widget.onDismiss,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
