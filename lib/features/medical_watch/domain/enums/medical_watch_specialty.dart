import 'package:medicail/core/i18n/app_localizations.dart';

/// Spécialités de veille médicale alignées sur les valeurs backend.
enum MedicalWatchSpecialty {
  rehabilitation('rehabilitation'),
  musculoskeletal('musculoskeletal'),
  exerciseTherapy('exercise_therapy'),
  manualTherapy('manual_therapy');

  const MedicalWatchSpecialty(this.value);

  /// Valeur envoyée / reçue par l'API backend (snake_case).
  final String value;

  /// Libellé localisé pour l'affichage dans l'UI.
  ///
  /// Nécessite un [AppLocalizations] obtenu via `AppLocalizations.of(context)`.
  String label(AppLocalizations l10n) {
    switch (this) {
      case MedicalWatchSpecialty.rehabilitation:
        return l10n.medicalWatchSpecialtyRehabilitation;
      case MedicalWatchSpecialty.musculoskeletal:
        return l10n.medicalWatchSpecialtyMusculoskeletal;
      case MedicalWatchSpecialty.exerciseTherapy:
        return l10n.medicalWatchSpecialtyExerciseTherapy;
      case MedicalWatchSpecialty.manualTherapy:
        return l10n.medicalWatchSpecialtyManualTherapy;
    }
  }

  /// Résout une instance depuis la valeur API (ex: `"exercise_therapy"`).
  /// Retourne `null` si la valeur est inconnue.
  static MedicalWatchSpecialty? fromValue(String? value) {
    if (value == null) return null;
    for (final specialty in values) {
      if (specialty.value == value) return specialty;
    }
    return null;
  }
}
