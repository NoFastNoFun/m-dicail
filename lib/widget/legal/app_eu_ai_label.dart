import 'package:flutter/material.dart';
import 'package:medicail/core/i18n/app_localizations.dart';

enum EuAiLabelKind {
  generated,
  modified,
}

/// Official EU AI Act disclosure pill (rectangular asset).
class AppEuAiLabel extends StatelessWidget {
  const AppEuAiLabel({
    super.key,
    required this.kind,
    this.height = 22,
  });

  final EuAiLabelKind kind;
  final double height;

  static const String _generatedBlack =
      'assets/images/legal_ai/LABEL_AI GENERATED_black.png';
  static const String _generatedWhite =
      'assets/images/legal_ai/LABEL_AI GENERATED_white.png';
  static const String _modifiedBlack =
      'assets/images/legal_ai/LABEL_AI MODIFIED_black.png';
  static const String _modifiedWhite =
      'assets/images/legal_ai/LABEL_AI MODIFIED_white.png';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final assetPath = switch (kind) {
      EuAiLabelKind.generated => isDark ? _generatedWhite : _generatedBlack,
      EuAiLabelKind.modified => isDark ? _modifiedWhite : _modifiedBlack,
    };
    final semanticLabel = switch (kind) {
      EuAiLabelKind.generated => l10n.euAiLabelGenerated,
      EuAiLabelKind.modified => l10n.euAiLabelModified,
    };

    return Semantics(
      label: semanticLabel,
      image: true,
      child: Image.asset(
        assetPath,
        height: height,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
