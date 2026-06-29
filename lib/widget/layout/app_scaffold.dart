import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/debug/debug_menu.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/widget/app_text.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, this.title, required this.body, this.actions});

  final String? title;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: title != null ? _AppBarTitle(title: title!) : null,
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                color: AppColors.textPrimary,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => context.pop(),
              )
            : null,
        actions: actions == null
            ? null
            : [...actions!, if (kDebugMode) const SizedBox(width: 48)],
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
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
