import 'package:medicail/features/pathology/domain/entities/pathology.dart';

class PathologySuggestion {
  const PathologySuggestion({
    required this.pathology,
    required this.score,
  });

  final Pathology pathology;
  final int score;
}

abstract final class PathologySuggestionMatcher {
  static const _stopWords = {
    'de',
    'du',
    'des',
    'la',
    'le',
    'les',
    'et',
    'en',
    'post',
    'op',
  };

  static PathologySuggestion? suggest({
    required String transcript,
    required List<Pathology> pathologies,
    int minScore = 2,
  }) {
    final normalized = _normalize(transcript);
    if (normalized.isEmpty || pathologies.isEmpty) {
      return null;
    }

    PathologySuggestion? best;
    for (final pathology in pathologies) {
      final score = _scorePathology(normalized, pathology);
      if (score < minScore) {
        continue;
      }
      if (best == null || score > best.score) {
        best = PathologySuggestion(pathology: pathology, score: score);
      }
    }
    return best;
  }

  static int _scorePathology(String normalizedTranscript, Pathology pathology) {
    var score = 0;
    for (final keyword in _keywordsFor(pathology)) {
      if (normalizedTranscript.contains(keyword)) {
        score++;
      }
    }
    return score;
  }

  static Iterable<String> _keywordsFor(Pathology pathology) sync* {
    for (final part in pathology.name.toLowerCase().split(RegExp(r'\s+'))) {
      if (part.length >= 3 && !_stopWords.contains(part)) {
        yield part;
      }
    }

    final meshTerm = pathology.meshTerm;
    if (meshTerm != null) {
      for (final part in meshTerm.toLowerCase().split(RegExp(r'\s+'))) {
        if (part.length >= 3 && !_stopWords.contains(part)) {
          yield part;
        }
      }
    }

    for (final alias in pathology.aliases) {
      final normalized = _normalize(alias);
      if (normalized.isNotEmpty) {
        yield normalized;
      }
    }
  }

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
