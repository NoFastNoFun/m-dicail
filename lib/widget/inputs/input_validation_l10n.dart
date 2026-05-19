import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/widget/inputs/input_validators.dart';

String resolveInputValidationMessage(AppLocalizations l10n, String key) {
  return switch (key) {
    InputValidationKeys.required => l10n.inputErrorRequired,
    InputValidationKeys.email => l10n.inputErrorEmail,
    InputValidationKeys.number => l10n.inputErrorNumber,
    InputValidationKeys.password => l10n.inputErrorPassword,
    _ => l10n.inputErrorRequired,
  };
}
