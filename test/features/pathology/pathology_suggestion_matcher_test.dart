import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/features/pathology/domain/entities/pathology.dart';
import 'package:medicail/features/pathology/domain/entities/pathology_domain.dart';
import 'package:medicail/features/pathology/domain/entities/pathology_source.dart';
import 'package:medicail/features/pathology/domain/utils/pathology_suggestion_matcher.dart';

Pathology _pathology({
  required String id,
  required String name,
  List<String> aliases = const [],
}) {
  return Pathology(
    id: id,
    name: name,
    domain: PathologyDomain.musculoskeletal,
    source: PathologySource.builtIn,
    aliases: aliases,
  );
}

void main() {
  final pathologies = [
    _pathology(
      id: 'path_ankle_sprain',
      name: 'Entorse de cheville',
      aliases: ['entorse', 'cheville'],
    ),
    _pathology(
      id: 'path_low_back_pain',
      name: 'Lombalgie',
      aliases: ['lombalgie', 'lombaire', 'lombaires', 'dos'],
    ),
    _pathology(
      id: 'path_neck_pain',
      name: 'Cervicalgie',
      aliases: ['cervicalgie', 'cou'],
    ),
  ];

  test('suggests lombalgie from lumbar transcript', () {
    final suggestion = PathologySuggestionMatcher.suggest(
      transcript:
          'Le patient presente une lombalgie avec douleur lombaire depuis trois semaines.',
      pathologies: pathologies,
    );

    expect(suggestion, isNotNull);
    expect(suggestion!.pathology.id, 'path_low_back_pain');
  });

  test('returns null when transcript has no pathology signal', () {
    final suggestion = PathologySuggestionMatcher.suggest(
      transcript: 'Consultation de controle sans plainte particuliere.',
      pathologies: pathologies,
    );

    expect(suggestion, isNull);
  });

  test('suggestAll returns multiple hits sorted by score', () {
    final suggestions = PathologySuggestionMatcher.suggestAll(
      transcript:
          'Le patient presente une lombalgie lombaire et une cervicalgie au cou.',
      pathologies: pathologies,
    );

    expect(suggestions.length, greaterThanOrEqualTo(2));
    expect(
      suggestions.map((s) => s.pathology.id),
      containsAll(['path_low_back_pain', 'path_neck_pain']),
    );
    for (var i = 0; i < suggestions.length - 1; i++) {
      expect(suggestions[i].score, greaterThanOrEqualTo(suggestions[i + 1].score));
    }
  });

  test('suggestAll returns empty when no signal', () {
    final suggestions = PathologySuggestionMatcher.suggestAll(
      transcript: 'Consultation de controle sans plainte particuliere.',
      pathologies: pathologies,
    );

    expect(suggestions, isEmpty);
  });

  test('suggest returns first of suggestAll', () {
    final all = PathologySuggestionMatcher.suggestAll(
      transcript:
          'Le patient presente une lombalgie avec douleur lombaire depuis trois semaines.',
      pathologies: pathologies,
    );
    final one = PathologySuggestionMatcher.suggest(
      transcript:
          'Le patient presente une lombalgie avec douleur lombaire depuis trois semaines.',
      pathologies: pathologies,
    );

    expect(one, isNotNull);
    expect(one!.pathology.id, all.first.pathology.id);
  });
}
