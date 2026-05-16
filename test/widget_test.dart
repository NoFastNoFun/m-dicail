import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/utils/anonymization_helper.dart';

void main() {
  test('anonymization helper is available', () {
    expect(
      AnonymizationHelper.anonymize('test@mail.com'),
      contains('[ANONYMIZED]'),
    );
  });
}
