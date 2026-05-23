import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/features/templates/data/default_soap_templates.dart';
import 'package:medicail/features/templates/domain/entities/soap_template.dart';

void main() {
  test('default templates contains 10 pathologies', () {
    expect(DefaultSoapTemplates.all(), hasLength(10));
  });

  test('toSoapNote maps defaults to SoapNote fields', () {
    final template = SoapTemplate(
      id: 't1',
      pathologyName: 'Test',
      subjectiveDefault: 'S',
      objectiveDefault: 'O',
      assessmentDefault: 'A',
      planDefault: 'P',
      createdAt: DateTime.utc(2026, 1, 1),
    );

    final note = template.toSoapNote();
    expect(note.subjective, 'S');
    expect(note.objective, 'O');
    expect(note.assessment, 'A');
    expect(note.plan, 'P');
  });
}
