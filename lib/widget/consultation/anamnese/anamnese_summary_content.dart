import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/patient/domain/entities/anamnese.dart';

/// Presentation data shared by the compact and detailed read-only views.
class AnamneseSummaryField {
  const AnamneseSummaryField(this.label, this.value);

  final String label;
  final String? value;

  bool get isFilled => value?.trim().isNotEmpty ?? false;
}

class AnamneseSummarySection {
  const AnamneseSummarySection({
    required this.title,
    required this.fields,
    this.groups = const [],
  });

  final String title;
  final List<AnamneseSummaryField> fields;
  final List<List<AnamneseSummaryField>> groups;

  bool get isFilled =>
      fields.any((field) => field.isFilled) ||
      groups.any((group) => group.any((field) => field.isFilled));
}

List<AnamneseSummarySection> buildAnamneseSummary(
  Anamnese data,
  AppLocalizations l10n,
) {
  String? clean(String? value) =>
      value == null || value.trim().isEmpty ? null : value.trim();

  String? join(Iterable<String?> values, {String separator = ' — '}) {
    final filled = values.map(clean).whereType<String>().toList();
    return filled.isEmpty ? null : filled.join(separator);
  }

  String? labelled(String label, String? value) => clean(value) == null
      ? null
      : l10n.anamneseSummaryLabelValue(label, clean(value)!);

  String? boolean(bool? value) =>
      value == null ? null : (value ? l10n.anamneseOui : l10n.anamneseNon);

  String? presence(PresenceStatus status, Iterable<String?> details) {
    final description = join(details);
    if (status == PresenceStatus.unknown && description == null) return null;
    // Legacy details remain visible even when their status is unknown.
    return join([
      switch (status) {
        PresenceStatus.unknown => l10n.anamneseSummaryNotFilled,
        PresenceStatus.present => l10n.anamneseSummaryPresent,
        PresenceStatus.absent => l10n.anamneseSummaryAbsent,
      },
      description,
    ]);
  }

  String? condition(ConditionEntry entry, [List<String?> extra = const []]) =>
      presence(entry.status, [
        ...extra,
        labelled(l10n.anamneseAnnee, entry.year),
        entry.notes,
      ]);

  String? milestone(DevelopmentMilestone entry) => join([
    entry.status,
    if (clean(entry.ageMonths) case final age?) l10n.anamneseSummaryMonths(age),
    entry.notes,
  ]);

  String? habit(
    HabitEntry entry, {
    required String Function(String) quantityLabel,
    bool tobacco = false,
  }) => presence(entry.status, [
    entry.frequency,
    if (clean(entry.quantity) case final quantity?) quantityLabel(quantity),
    join(entry.types, separator: ', '),
    if (tobacco && entry.former) l10n.anamneseAncienFumeur,
    if (clean(entry.years) case final years?) l10n.anamneseSummaryYears(years),
    entry.notes,
  ]);

  String? chronic(ChroniqueFlag entry) {
    // This legacy boolean cannot distinguish an explicit absence from no answer.
    if (entry.isEmpty) return null;
    return presence(
      entry.enabled ? PresenceStatus.present : PresenceStatus.unknown,
      [
        labelled(l10n.anamneseAnnee, entry.annee),
        labelled(l10n.anamneseSuivi, entry.suivi),
        entry.notes,
      ],
    );
  }

  final birth = data.naissanceEnfance;
  final family = data.vieFamilialeSexuelle;
  final lifestyle = data.stylesDeVie;
  final physiology = data.activitesPhysiologiques;
  final work = data.activiteProfessionnelle;
  final personality = data.personnalite;
  final history = data.antecedentsChroniques;
  final trauma = data.traumatismesChirurgieInfections;
  final diseases = history.maladies.where((entry) => !entry.isEmpty);
  final surgeries = trauma.interventions.where((entry) => !entry.isEmpty);

  return [
    AnamneseSummarySection(
      title: l10n.anamneseNaissanceEnfanceTitle,
      fields: [
        AnamneseSummaryField(
          l10n.anamnesePoidsNaissance,
          clean(birth.poidsNaissance) == null
              ? null
              : join([birth.poidsNaissance, birth.poidsUnite], separator: ' '),
        ),
        AnamneseSummaryField(l10n.anamneseAllaitement, birth.allaitement),
        AnamneseSummaryField(l10n.anamneseMarche, milestone(birth.marche)),
        AnamneseSummaryField(
          l10n.anamneseDentition,
          milestone(birth.dentition),
        ),
        AnamneseSummaryField(
          l10n.anamnesePhonation,
          milestone(birth.phonation),
        ),
        AnamneseSummaryField(l10n.anamneseNotesComplementaires, birth.notes),
      ],
    ),
    AnamneseSummarySection(
      title: l10n.anamneseVieFamilialeTitle,
      fields: [
        AnamneseSummaryField(
          l10n.anamneseEnCouple,
          condition(family.enCouple, [
            family.coupleType,
            labelled(l10n.anamneseCoupleAnnee, family.coupleAnnee),
          ]),
        ),
        AnamneseSummaryField(
          l10n.anamneseNombreGrossesses,
          family.nombreGrossesses,
        ),
        AnamneseSummaryField(
          l10n.anamneseTroublesSexuels,
          condition(family.troublesSexuels, [
            join(family.troublesSexuelsTypes, separator: ', '),
          ]),
        ),
        AnamneseSummaryField(
          l10n.anamneseMenopause,
          condition(family.menopause),
        ),
        AnamneseSummaryField(
          l10n.anamneseTraitementHormonal,
          boolean(family.traitementHormonal),
        ),
        AnamneseSummaryField(l10n.anamneseNotesComplementaires, family.notes),
      ],
    ),
    AnamneseSummarySection(
      title: l10n.anamneseStylesDeVieTitle,
      fields: [
        AnamneseSummaryField(
          l10n.anamneseAlimentation,
          join([
            labelled(l10n.anamneseQualite, lifestyle.alimentation.qualite),
            labelled(l10n.anamneseQuantite, lifestyle.alimentation.quantite),
            lifestyle.alimentation.notes,
          ]),
        ),
        AnamneseSummaryField(
          l10n.anamneseAlcool,
          habit(
            lifestyle.alcool,
            quantityLabel: l10n.anamneseSummaryGlassesPerWeek,
          ),
        ),
        AnamneseSummaryField(
          l10n.anamneseTabac,
          habit(
            lifestyle.tabac,
            quantityLabel: l10n.anamneseSummaryCigarettesPerDay,
            tobacco: true,
          ),
        ),
        AnamneseSummaryField(
          l10n.anamneseDrogues,
          habit(
            lifestyle.drogues,
            quantityLabel: (value) =>
                l10n.anamneseSummaryLabelValue(l10n.anamneseQuantite, value),
          ),
        ),
        AnamneseSummaryField(l10n.anamneseSedentarite, lifestyle.sedentarite),
        AnamneseSummaryField(
          l10n.anamneseActiviteSemaine,
          lifestyle.activiteParSemaine,
        ),
        AnamneseSummaryField(
          l10n.anamneseRelationsSociales,
          lifestyle.relationsSociales,
        ),
        AnamneseSummaryField(
          l10n.anamneseAllergies,
          presence(lifestyle.allergies.status, [
            join(lifestyle.allergies.types, separator: ', '),
            lifestyle.allergies.notes,
          ]),
        ),
        AnamneseSummaryField(
          l10n.anamneseNotesComplementaires,
          lifestyle.notes,
        ),
      ],
    ),
    AnamneseSummarySection(
      title: l10n.anamneseActivitesPhysioTitle,
      fields: [
        AnamneseSummaryField(
          l10n.anamneseSelles,
          join([
            physiology.selles.rythme,
            labelled(l10n.anamneseFrequenceJour, physiology.selles.frequence),
            physiology.selles.notes,
          ]),
        ),
        AnamneseSummaryField(
          l10n.anamneseMictions,
          join([
            join(physiology.mictions.symptomes, separator: ', '),
            labelled(l10n.anamneseFrequenceJour, physiology.mictions.frequence),
            labelled(l10n.anamneseCouleur, physiology.mictions.couleur),
            physiology.mictions.notes,
          ]),
        ),
        AnamneseSummaryField(
          l10n.anamneseNotesComplementaires,
          physiology.notes,
        ),
      ],
    ),
    AnamneseSummarySection(
      title: l10n.anamneseActiviteProTitle,
      fields: [
        AnamneseSummaryField(l10n.anamneseTypeActivite, work.categorie),
        AnamneseSummaryField(l10n.anamneseMetier, work.metier),
        AnamneseSummaryField(
          l10n.anamneseExpositions,
          condition(work.expositions, [
            join(work.expositionTypes, separator: ', '),
          ]),
        ),
        AnamneseSummaryField(l10n.anamneseNotesComplementaires, work.notes),
      ],
    ),
    AnamneseSummarySection(
      title: l10n.anamnesePersonnaliteTitle,
      fields: [
        AnamneseSummaryField(
          l10n.anamneseEtudesTravail,
          personality.etudesTravail,
        ),
        AnamneseSummaryField(
          l10n.anamnesePerceptionSante,
          personality.perceptionSante,
        ),
        AnamneseSummaryField(
          l10n.anamneseAttitudeMaladie,
          join(personality.attitudeMaladie, separator: ', '),
        ),
        AnamneseSummaryField(
          l10n.anamneseNotesComplementaires,
          personality.notes,
        ),
      ],
    ),
    AnamneseSummarySection(
      title: l10n.anamneseAntecedentsTitle,
      fields: [
        AnamneseSummaryField(
          l10n.anamneseHypertension,
          chronic(history.hypertension),
        ),
        AnamneseSummaryField(l10n.anamneseDiabete, chronic(history.diabete)),
        AnamneseSummaryField(
          l10n.anamneseDyslipidemie,
          chronic(history.dyslipidemie),
        ),
        if (diseases.isEmpty)
          AnamneseSummaryField(l10n.anamneseMaladieName, null),
        AnamneseSummaryField(l10n.anamneseNotesComplementaires, history.notes),
      ],
      groups: [
        for (final disease in diseases)
          [
            AnamneseSummaryField(l10n.anamneseMaladieName, disease.name),
            AnamneseSummaryField(
              l10n.anamneseMaladieAnnee,
              disease.anneeApparition,
            ),
            AnamneseSummaryField(
              l10n.anamneseMaladieSymptomes,
              disease.symptomesDebut,
            ),
            AnamneseSummaryField(
              l10n.anamneseMaladieLieuSuivi,
              disease.lieuSuivi,
            ),
            AnamneseSummaryField(
              l10n.anamneseMaladieModaliteSuivi,
              disease.modaliteSuivi,
            ),
          ],
      ],
    ),
    AnamneseSummarySection(
      title: l10n.anamneseTraumatismesTitle,
      fields: [
        AnamneseSummaryField(
          l10n.anamneseTraumatismesSequelles,
          condition(trauma.traumatismesSequelles),
        ),
        // False is also the legacy default: do not invent an explicit absence.
        AnamneseSummaryField(
          l10n.anamneseChirurgieAnterieure,
          boolean(trauma.chirurgieAnterieure ? true : null),
        ),
        if (surgeries.isEmpty)
          AnamneseSummaryField(l10n.anamneseInterventionDesc, null),
        AnamneseSummaryField(
          l10n.anamneseInfectionsEnfance,
          condition(trauma.infectionsEnfance),
        ),
        AnamneseSummaryField(
          l10n.anamneseTuberculose,
          condition(trauma.tuberculose),
        ),
        AnamneseSummaryField(l10n.anamneseTumeurs, condition(trauma.tumeurs)),
        AnamneseSummaryField(l10n.anamneseHepatite, condition(trauma.hepatite)),
        AnamneseSummaryField(l10n.anamneseSyphilis, condition(trauma.syphilis)),
        AnamneseSummaryField(
          l10n.anamneseFracturesSansTraumatisme,
          condition(trauma.fracturesSansTraumatisme),
        ),
        AnamneseSummaryField(l10n.anamneseNotesComplementaires, trauma.notes),
      ],
      groups: [
        for (final surgery in surgeries)
          [
            AnamneseSummaryField(
              l10n.anamneseInterventionDesc,
              surgery.description,
            ),
            AnamneseSummaryField(l10n.anamneseInterventionDate, surgery.date),
            AnamneseSummaryField(
              l10n.anamneseInterventionComplications,
              surgery.complications,
            ),
          ],
      ],
    ),
  ];
}
