import 'package:flutter/material.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_scaffold.dart';

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
          Text(
            l10n.labelHistory,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: Text(
                l10n.historyEmpty,
                style: Theme.of(context).textTheme.bodyLarge,
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
