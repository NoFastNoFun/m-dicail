import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/features/templates/data/default_soap_templates.dart';
import 'package:medicail/features/templates/domain/repositories/template_repository.dart';
import 'package:medicail/features/templates/domain/services/template_suggestion_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockTemplateRepository extends Mock implements TemplateRepository {}

void main() {
  late _MockTemplateRepository repository;
  late TemplateSuggestionService service;

  setUp(() {
    repository = _MockTemplateRepository();
    when(() => repository.ensureSeeded()).thenAnswer((_) async {});
    when(() => repository.getBuiltinTemplates()).thenAnswer(
      (_) async => DefaultSoapTemplates.all(),
    );
    service = TemplateSuggestionService(repository);
  });

  test('returns lombalgie when transcript mentions lombalgie', () async {
    final result = await service.suggest(
      'Patient avec lombalgie chronique depuis 2 semaines',
    );

    expect(result, isNotNull);
    expect(result!.template.id, 'template_lombalgie_commune');
    expect(result.score, greaterThanOrEqualTo(1));
  });

  test('returns null for empty transcript', () async {
    final result = await service.suggest('   ');
    expect(result, isNull);
  });

  test('returns null when no keywords match', () async {
    final result = await service.suggest('Consultation generale sans symptome');
    expect(result, isNull);
  });

  test('picks highest score when multiple pathologies mentioned', () async {
    final result = await service.suggest(
      'Entorse de cheville avec oedeme, critere ottawa negatif',
    );

    expect(result, isNotNull);
    expect(result!.template.id, 'template_entorse_cheville');
  });
}
