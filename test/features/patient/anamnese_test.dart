import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/features/patient/domain/entities/anamnese.dart';

void main() {
  group('Anamnese', () {
    test('fromJson/toJson round-trip preserves fields', () {
      const original = Anamnese(
        naissanceEnfance: NaissanceEnfance(
          poidsNaissance: '3.2 kg',
          allaitement: 'maternel',
          marche: '12 mois',
        ),
        stylesDeVie: StylesDeVie(
          tabac: 'non',
          alcool: 'occasionnel',
          allergies: 'pénicilline',
        ),
        antecedentsChroniques: AntecedentsChroniques(
          hypertension: true,
          diabete: false,
          dyslipidemie: true,
          maladies: [
            MaladieChroniqueEntry(
              name: 'Asthme',
              anneeApparition: '2010',
              symptomesDebut: 'dyspnée',
              lieuSuivi: 'Pneumologue',
              modaliteSuivi: 'annuel',
            ),
          ],
        ),
        traumatismesChirurgieInfections: TraumatismesChirurgieInfections(
          traumatismesSequelles: 'entorse cheville',
          interventions: [
            InterventionChirurgicaleEntry(
              description: 'Appendicectomie',
              date: '2005',
              complications: 'aucune',
            ),
          ],
          tuberculose: 'non',
        ),
      );

      final json = original.toJson();
      final restored = Anamnese.fromJson(json);

      expect(restored, original);
      expect(restored.naissanceEnfance.allaitement, 'maternel');
      expect(restored.antecedentsChroniques.hypertension, isTrue);
      expect(restored.antecedentsChroniques.maladies.single.name, 'Asthme');
      expect(
        restored.traumatismesChirurgieInfections.interventions.single
            .description,
        'Appendicectomie',
      );
    });

    test('empty anamnèse reports isEmpty', () {
      expect(const Anamnese().isEmpty, isTrue);
      expect(
        const Anamnese(
          stylesDeVie: StylesDeVie(tabac: 'oui'),
        ).isEmpty,
        isFalse,
      );
    });

    test('metadata helpers store birthPlace and anamnese', () {
      final metadata = <String, dynamic>{}
          .withBirthPlace('Lyon')
          .withAnamnese(
            const Anamnese(
              personnalite: Personnalite(attitudeMaladie: 'acceptation'),
            ),
          );

      expect(metadata.birthPlace, 'Lyon');
      expect(metadata.anamnese.personnalite.attitudeMaladie, 'acceptation');

      final cleared = metadata.withBirthPlace(null).withAnamnese(const Anamnese());
      expect(cleared.birthPlace, isNull);
      expect(cleared.containsKey(PatientMetadataKeys.anamnese), isFalse);
    });
  });
}
