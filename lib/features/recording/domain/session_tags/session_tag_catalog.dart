import 'package:medicail/core/i18n/app_localizations.dart';

/// Small configurable preset set for practitioner session tags.
/// Free-form tags are allowed in addition to these presets.
abstract final class SessionTagCatalog {
  static const String bilan = 'bilan';
  static const String suivi = 'suivi';
  static const String urgence = 'urgence';

  static const List<String> presets = [bilan, suivi, urgence];

  static String label(AppLocalizations l10n, String tag) {
    return switch (tag.trim().toLowerCase()) {
      bilan => l10n.sessionTagPresetBilan,
      suivi => l10n.sessionTagPresetSuivi,
      urgence => l10n.sessionTagPresetUrgence,
      _ => tag.trim(),
    };
  }

  static String? normalize(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final lower = trimmed.toLowerCase();
    for (final preset in presets) {
      if (lower == preset) return preset;
    }
    return trimmed;
  }
}
