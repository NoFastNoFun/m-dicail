import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/utils/anonymization_helper.dart';

void main() {
  group('AnonymizationHelper', () {
    test('masks email addresses', () {
      const input = 'Contact: patient@example.com pour suivi';
      final result = AnonymizationHelper.anonymize(input);
      expect(result, contains('[ANONYMIZED]'));
      expect(result, isNot(contains('patient@example.com')));
    });

    test('masks french phone numbers', () {
      const input = 'Appeler le 06 12 34 56 78 demain';
      final result = AnonymizationHelper.anonymize(input);
      expect(result, contains('[ANONYMIZED]'));
      expect(result, isNot(contains('06 12 34 56 78')));
    });

    test('masks date formats', () {
      const input = 'Ne(e) le 15/03/1990';
      final result = AnonymizationHelper.anonymize(input);
      expect(result, contains('[ANONYMIZED]'));
    });

    test('returns empty string unchanged', () {
      expect(AnonymizationHelper.anonymize(''), '');
    });
  });
}
