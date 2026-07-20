import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/router/app_routes.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/buttons/app_button.dart';
import 'package:medicail/widget/feedback/app_dialog.dart';

/// Debug-only entry: long-press the page title to open the component gallery.
abstract final class DebugMenu {
  static Future<void> showEntryDialog(BuildContext context) async {
    if (!kDebugMode) return;

    final l10n = AppLocalizations.of(context);

    final open = await AppDialog.show<bool>(
      context,
      variant: AppDialogVariant.standard,
      title: l10n.debugShakeTitle,
      body: AppText(l10n.debugShakeMessage, variant: AppTextVariant.body),
      actionsBuilder: (dialogContext) => [
        AppButton(
          layout: AppButtonLayout.text,
          label: l10n.debugShakeCancel,
          style: AppButtonStyle.secondary,
          expanded: false,
          onPressed: () => Navigator.of(dialogContext).pop(false),
        ),
        AppButton(
          layout: AppButtonLayout.text,
          label: l10n.debugShakeConfirm,
          expanded: false,
          onPressed: () => Navigator.of(dialogContext).pop(true),
        ),
      ],
    );

    if (open == true && context.mounted) {
      context.push(AppRoutes.debug);
    }
  }
}
