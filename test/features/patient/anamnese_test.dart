import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/features/patient/domain/entities/anamnese.dart';

void main() {
  group('Anamnese', () {
    test('structured fromJson/toJson round-trip', () {
      const original = Anamnese(
        naissanceEnfance: NaissanceEnfance(
          poidsNaissance: '3.2',
          poidsUnite: 'kg',
          allaitement: 'maternel',
          marche: DevelopmentMilestone(status: 'normal'),
        ),
        stylesDeVie: StylesDeVie(
          alcool: HabitEntry(
            status: PresenceStatus.present,
            frequency: 'hebdo',
            quantity: '7',
            types: ['vin'],
          ),
          tabac: HabitEntry(status: PresenceStatus.absent),
          allergies: AllergiesEntry(
            status: PresenceStatus.present,
            types: ['medicamenteuses'],
            notes: 'pénicilline',
          ),
        ),
        antecedentsChroniques: AntecedentsChroniques(
          hypertension: ChroniqueFlag(
            enabled: true,
            annee: '2015',
            suivi: 'mt',
          ),
        ),
        traumatismesChirurgieInfections: TraumatismesChirurgieInfections(
          tuberculose: ConditionEntry(
            status: PresenceStatus.present,
            year: '1998',
          ),
        ),
      );

      final restored = Anamnese.fromJson(original.toJson());
      expect(restored, original);
      expect(restored.stylesDeVie.alcool.types, ['vin']);
      expect(restored.antecedentsChroniques.hypertension.enabled, isTrue);
    });

    test('legacy string alcool migrates to HabitEntry', () {
      final styles = StylesDeVie.fromJson({
        'alcool': '2 verres/j',
        'tabac': '',
        'allergies': 'pollen',
      });
      expect(styles.alcool.status, PresenceStatus.present);
      expect(styles.alcool.notes, '2 verres/j');
      expect(styles.tabac.status, PresenceStatus.absent);
      expect(styles.allergies.status, PresenceStatus.present);
      expect(styles.allergies.notes, 'pollen');
    });

    test('legacy bool hypertension migrates to ChroniqueFlag', () {
      final antecedents = AntecedentsChroniques.fromJson({
        'hypertension': true,
        'diabete': false,
      });
      expect(antecedents.hypertension.enabled, isTrue);
      expect(antecedents.diabete.enabled, isFalse);
    });

    test('empty anamnèse reports isEmpty', () {
      expect(const Anamnese().isEmpty, isTrue);
      expect(
        const Anamnese(
          stylesDeVie: StylesDeVie(
            alcool: HabitEntry(status: PresenceStatus.present),
          ),
        ).isEmpty,
        isFalse,
      );
    });

    test('HabitEntry.clearedDetails resets detail fields', () {
      const filled = HabitEntry(
        status: PresenceStatus.present,
        frequency: 'quotidien',
        quantity: '10',
        types: ['biere'],
        notes: 'soir',
      );
      final cleared =
          filled.clearedDetails(status: PresenceStatus.absent);
      expect(cleared.status, PresenceStatus.absent);
      expect(cleared.frequency, isNull);
      expect(cleared.types, isEmpty);
      expect(cleared.notes, isNull);
    });

    test('metadata helpers store birthPlace and anamnese', () {
      final metadata = <String, dynamic>{}
          .withBirthPlace('Lyon')
          .withAnamnese(
            const Anamnese(
              personnalite: Personnalite(
                attitudeMaladie: ['acceptation'],
              ),
            ),
          );

      expect(metadata.birthPlace, 'Lyon');
      expect(
        metadata.anamnese.personnalite.attitudeMaladie,
        ['acceptation'],
      );

      final cleared =
          metadata.withBirthPlace(null).withAnamnese(const Anamnese());
      expect(cleared.birthPlace, isNull);
      expect(cleared.containsKey(PatientMetadataKeys.anamnese), isFalse);
    });
  });
}
