import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/debug/debug_menu.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/layout/app_breakpoints.dart';
import 'package:medicail/core/layout/app_content_constraint.dart';
import 'package:medicail/core/layout/main_shell_chrome.dart';
import 'package:medicail/core/router/app_routes.dart';
import 'package:medicail/widget/app_text.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.contentMaxWidth,
    this.constrainBody = true,
    this.hideAppBar = false,
  });

  final String? title;
  final Widget body;
  final List<Widget>? actions;

  /// Override the default content cap (see [AppBreakpoints.contentMaxWidth]).
  final double? contentMaxWidth;

  /// When false, [body] spans the full width (rare; prefer default).
  final bool constrainBody;

  /// Hide the app bar when there is no back affordance (e.g. auth welcome).
  final bool hideAppBar;

  static const _shellRootRoutes = {
    AppRoutes.home,
    AppRoutes.appointments,
    AppRoutes.patients,
    AppRoutes.settings,
    AppRoutes.medicalWatch,
  };

  bool _shouldShowBack(BuildContext context) {
    if (!context.canPop()) {
      return false;
    }
    if (MainShellScope.isActive(context)) {
      final location = GoRouterState.of(context).matchedLocation;
      if (_shellRootRoutes.contains(location)) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final showBack = _shouldShowBack(context);

    final theme = Theme.of(context);
    final insideMainShell = MainShellScope.isActive(context);
    final padding = AppLayout.pagePadding(context);

    Widget bodyChild = Padding(padding: padding, child: body);

    if (constrainBody) {
      bodyChild = AppContentConstraint(
        maxWidth: contentMaxWidth,
        child: bodyChild,
      );
    }

    final hideBar = hideAppBar && !showBack && title == null &&
        (actions == null || actions!.isEmpty);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: hideBar
          ? null
          : AppBar(
              backgroundColor: theme.scaffoldBackgroundColor,
              foregroundColor: theme.colorScheme.onSurface,
              title: title != null ? _AppBarTitle(title: title!) : null,
              centerTitle: !AppLayout.isExpanded(context),
              automaticallyImplyLeading: false,
              leading: showBack
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: theme.colorScheme.onSurface,
                      tooltip:
                          MaterialLocalizations.of(context).backButtonTooltip,
                      onPressed: () => context.pop(),
                    )
                  : null,
              actions: actions,
            ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SafeArea(bottom: !insideMainShell, child: bodyChild),
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final titleWidget = AppText(title, variant: AppTextVariant.title);

    if (!kDebugMode) return titleWidget;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => DebugMenu.showEntryDialog(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: titleWidget,
      ),
    );
  }
}
