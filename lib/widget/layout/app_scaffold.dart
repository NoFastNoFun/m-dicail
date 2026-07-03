import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/debug/debug_menu.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/layout/main_shell_chrome.dart';
import 'package:medicail/widget/app_text.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
  });

  final String? title;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();

    final theme = Theme.of(context);
    final insideMainShell = MainShellScope.isActive(context);
    final floatingBottomPadding =
        insideMainShell ? MainShellChrome.bottomInset(context) : 0.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onSurface,
        title: title != null ? _AppBarTitle(title: title!) : null,
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                color: theme.colorScheme.onSurface,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => context.pop(),
              )
            : null,
        actions: actions,
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          bottom: !insideMainShell,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pagePadding,
              AppSpacing.pagePadding,
              AppSpacing.pagePadding,
              AppSpacing.pagePadding + floatingBottomPadding,
            ),
            child: body,
          ),
        ),
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
