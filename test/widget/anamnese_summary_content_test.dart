import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/i18n/app_localizations_fr.dart';
import 'package:medicail/features/patient/domain/entities/anamnese.dart';
import 'package:medicail/widget/consultation/anamnese/anamnese_summary_content.dart';

void main() {
  final l10n = AppLocalizationsFr();

  String? value(Anamnese data, String label) => buildAnamneseSummary(data, l10n)
      .expand(
        (section) => [
          ...section.fields,
          ...section.groups.expand((group) => group),
        ],
      )
      .firstWhere((field) => field.label == label)
      .value;

  test('unanswered fields stay null, including legacy false defaults', () {
    final sections = buildAnamneseSummary(const Anamnese(), l10n);
    expect(sections, hasLength(8));
    expect(sections.any((section) => section.isFilled), isFalse);
    expect(value(const Anamnese(), l10n.anamneseTraitementHormonal), isNull);
    expect(value(const Anamnese(), l10n.anamneseChirurgieAnterieure), isNull);
    expect(value(const Anamnese(), l10n.anamneseHypertension), isNull);
  });

  test('explicit absences and false nullable answers remain visible', () {
    const data = Anamnese(
      vieFamilialeSexuelle: VieFamilialeSexuelle(traitementHormonal: false),
      stylesDeVie: StylesDeVie(
        allergies: AllergiesEntry(status: PresenceStatus.absent),
      ),
    );
    expect(value(data, l10n.anamneseAllergies), l10n.anamneseSummaryAbsent);
    expect(value(data, l10n.anamneseTraitementHormonal), l10n.anamneseNon);
  });

  test('legacy family notes and unknown-status details are preserved', () {
    const data = Anamnese(
      vieFamilialeSexuelle: VieFamilialeSexuelle(
        enCouple: ConditionEntry(notes: 'Situation familiale documentée'),
        menopause: ConditionEntry(
          status: PresenceStatus.present,
          year: '2020',
          notes: 'Suivi annuel',
        ),
      ),
    );
    expect(
      value(data, l10n.anamneseEnCouple),
      contains('Situation familiale documentée'),
    );
    expect(
      value(data, l10n.anamneseEnCouple),
      startsWith(l10n.anamneseSummaryNotFilled),
    );
    expect(value(data, l10n.anamneseMenopause), contains('2020'));
    expect(value(data, l10n.anamneseMenopause), contains('Suivi annuel'));
  });

  test('ages and habit quantities include the editor units', () {
    const data = Anamnese(
      naissanceEnfance: NaissanceEnfance(
        marche: DevelopmentMilestone(ageMonths: '12'),
      ),
      stylesDeVie: StylesDeVie(
        alcool: HabitEntry(status: PresenceStatus.present, quantity: '3'),
        tabac: HabitEntry(
          status: PresenceStatus.present,
          quantity: '10',
          years: '5',
          former: true,
        ),
      ),
    );
    expect(value(data, l10n.anamneseMarche), '12 mois');
    expect(value(data, l10n.anamneseAlcool), contains('3 verres/semaine'));
    expect(value(data, l10n.anamneseTabac), contains('10 cigarettes/jour'));
    expect(value(data, l10n.anamneseTabac), contains('5 ans'));
    expect(
      value(data, l10n.anamneseTabac),
      contains(l10n.anamneseAncienFumeur),
    );
  });

  test('blank strings and blank list entries do not fill a section', () {
    const data = Anamnese(
      personnalite: Personnalite(notes: '  ', attitudeMaladie: [' ', '']),
    );
    expect(
      buildAnamneseSummary(data, l10n).any((section) => section.isFilled),
      isFalse,
    );
  });

  test(
    'diseases and surgeries preserve their separate entries and details',
    () {
      const data = Anamnese(
        antecedentsChroniques: AntecedentsChroniques(
          maladies: [
            MaladieChroniqueEntry(
              name: 'Asthme',
              lieuSuivi: 'Cabinet',
              modaliteSuivi: 'Annuel',
            ),
            MaladieChroniqueEntry(name: 'Arthrose', symptomesDebut: 'Douleurs'),
          ],
        ),
        traumatismesChirurgieInfections: TraumatismesChirurgieInfections(
          interventions: [
            InterventionChirurgicaleEntry(
              description: 'Appendicectomie',
              date: '2020',
              complications: 'Aucune',
            ),
          ],
        ),
      );
      final sections = buildAnamneseSummary(data, l10n);
      expect(sections[6].groups, hasLength(2));
      expect(sections[7].groups, hasLength(1));
      expect(value(data, l10n.anamneseMaladieModaliteSuivi), 'Annuel');
      expect(value(data, l10n.anamneseInterventionComplications), 'Aucune');
    },
  );
}
