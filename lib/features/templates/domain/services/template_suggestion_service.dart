import 'package:injectable/injectable.dart';
import 'package:medicail/features/templates/data/template_keywords.dart';
import 'package:medicail/features/templates/domain/entities/soap_template.dart';
import 'package:medicail/features/templates/domain/entities/template_suggestion.dart';
import 'package:medicail/features/templates/domain/repositories/template_repository.dart';
import 'package:medicail/features/templates/domain/utils/text_normalizer.dart';

@injectable
class TemplateSuggestionService {
  const TemplateSuggestionService(this._templateRepository);

  final TemplateRepository _templateRepository;

  Future<TemplateSuggestion?> suggest(String transcript) async {
    final trimmed = transcript.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    await _templateRepository.ensureSeeded();
    final templates = await _templateRepository.getBuiltinTemplates();
    if (templates.isEmpty) {
      return null;
    }

    final normalizedText = TextNormalizer.normalize(trimmed);
    final scores = <SoapTemplate, int>{};

    for (final template in templates) {
      final keywords = TemplateKeywords.forTemplate(template.id);
      final score = TextNormalizer.countKeywordMatches(normalizedText, keywords);
      if (score > 0) {
        scores[template] = score;
      }
    }

    if (scores.isEmpty) {
      return null;
    }

    final ranked = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final best = ranked.first;
    if (best.value < 1) {
      return null;
    }

    final alternatives = <SoapTemplate>[];
    for (var i = 1; i < ranked.length && alternatives.length < 3; i++) {
      final entry = ranked[i];
      if (entry.value >= best.value - 1) {
        alternatives.add(entry.key);
      }
    }

    return TemplateSuggestion(
      template: best.key,
      score: best.value,
      alternatives: alternatives,
    );
  }
}
