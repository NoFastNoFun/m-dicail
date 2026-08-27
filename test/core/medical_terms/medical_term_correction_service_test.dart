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
    // ignore: avoid_print
    print('"$input" -> "$result"');
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
  });
}
