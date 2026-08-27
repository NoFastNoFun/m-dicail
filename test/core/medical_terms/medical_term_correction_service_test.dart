import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/medical_terms/medical_root_dictionary.dart';
import 'package:medicail/core/medical_terms/medical_term_correction_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MedicalTermCorrectionService service;

  setUp(() {
    service = MedicalTermCorrectionService(MedicalRootDictionary());
  });

  Future<void> expectCorrection(String input, String expected) async {
    final result = await service.correct(input);
    expect(result, expected);
  }

  group('MedicalTermCorrectionService', () {
    test('leaves an already-correct known term unchanged', () async {
      await expectCorrection('tendinite', 'tendinite');
    });

    test('fixes a slightly misheard known term', () async {
      await expectCorrection('tendinnite', 'tendinite');
    });

    test('restores accents on an unaccented match', () async {
      await expectCorrection('epicondylite', 'épicondylite');
    });

    test(
      'corrects a term inside a full sentence, leaving the rest intact',
      () async {
        await expectCorrection(
          "le patient se plaint d'une tendinnite au coude depuis 3 semaines.",
          "le patient se plaint d'une tendinite au coude depuis 3 semaines.",
        );
      },
    );

    test('preserves capitalization at the start of a sentence', () async {
      await expectCorrection('Tendinnite du coude', 'Tendinite du coude');
    });

    test('does not touch unrelated common words', () async {
      await expectCorrection(
        'le patient a une chaise bleue',
        'le patient a une chaise bleue',
      );
    });

    test('returns the input unchanged when empty', () async {
      await expectCorrection('', '');
    });

    test('leaves an already-correct multi-word phrase unchanged', () async {
      await expectCorrection('hernie discale', 'hernie discale');
    });

    test('fixes a slightly misheard multi-word phrase', () async {
      await expectCorrection('ernie diskale', 'hernie discale');
    });

    test(
      'corrects a multi-word phrase inside surrounding text',
      () async {
        await expectCorrection(
          'une ernie diskale L5',
          'une hernie discale L5',
        );
      },
    );

    test('still corrects the single-word term hernie on its own', () async {
      await expectCorrection('ernie', 'hernie');
    });

    test(
      'does not glue a multi-word phrase across punctuation',
      () async {
        await expectCorrection('hernie, discale', 'hernie, discale');
      },
    );
  });
}
