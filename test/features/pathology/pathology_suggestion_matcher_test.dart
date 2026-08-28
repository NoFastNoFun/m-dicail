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
}
