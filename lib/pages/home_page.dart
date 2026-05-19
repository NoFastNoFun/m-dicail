import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.homeTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(l10n.labelHistory, variant: AppTextVariant.title),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: Center(
              child: AppText(
                l10n.historyEmpty,
                variant: AppTextVariant.body,
              ),
            ),
          ),
          AppButton(
            label: l10n.navigateToRecord,
            onPressed: () => context.goRecord(),
          ),
        ],
      ),
    );
  }
}
