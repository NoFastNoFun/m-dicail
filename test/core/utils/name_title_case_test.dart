import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/utils/name_title_case.dart';

void main() {
  group('nameTitleCase', () {
    test('returns empty for blank input', () {
      expect(nameTitleCase(''), '');
      expect(nameTitleCase('   '), '');
    });

    test('title-cases mixed and lower input', () {
      expect(nameTitleCase('jean dupont'), 'Jean Dupont');
      expect(nameTitleCase('Jean Dupont'), 'Jean Dupont');
    });

    test('title-cases all caps', () {
      expect(nameTitleCase('JEAN DUPONT'), 'Jean Dupont');
    });

    test('preserves hyphenated parts', () {
      expect(nameTitleCase('JEAN-PIERRE'), 'Jean-Pierre');
      expect(nameTitleCase('marie-claire martin'), 'Marie-Claire Martin');
    });

    test('handles accents', () {
      expect(nameTitleCase('élodie'), 'Élodie');
      expect(nameTitleCase('ÉLODIE'), 'Élodie');
    });

    test('collapses extra whitespace', () {
      expect(nameTitleCase('  jean   dupont  '), 'Jean Dupont');
    });
  });
}
