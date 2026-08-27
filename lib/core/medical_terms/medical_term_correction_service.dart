import 'package:injectable/injectable.dart';
import 'package:medicail/core/medical_terms/medical_root_dictionary.dart';

@lazySingleton
class MedicalTermCorrectionService {
  MedicalTermCorrectionService(this._dictionary);

  final MedicalRootDictionary _dictionary;

  static const _shortWordLengthThreshold = 6;
  static const _maxDistanceForShortWord = 1;
  static const _maxDistanceForLongWord = 2;

  static final RegExp _wordPattern = RegExp(r"[\p{L}'-]+", unicode: true);

  static const Map<String, String> _accentReplacements = {
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'î': 'i',
    'ï': 'i',
    'ô': 'o',
    'ö': 'o',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
  };

  Future<void> warmUp() => _dictionary.load();

  Future<String> correct(String text) async {
    if (text.isEmpty) {
      return text;
    }

    final dictionary = await _dictionary.load();
    final normalizedTerms = <String, String>{
      for (final term in dictionary.knownTerms) _normalize(term): term,
    };

    if (normalizedTerms.isEmpty) {
      return text;
    }

    final buffer = StringBuffer();
    var lastEnd = 0;
    for (final match in _wordPattern.allMatches(text)) {
      buffer.write(text.substring(lastEnd, match.start));
      buffer.write(_correctWord(match.group(0)!, normalizedTerms));
      lastEnd = match.end;
    }
    buffer.write(text.substring(lastEnd));
    return buffer.toString();
  }

  String _correctWord(String word, Map<String, String> normalizedTerms) {
    final normalized = _normalize(word);

    final exact = normalizedTerms[normalized];
    if (exact != null) {
      return _preserveCase(word, exact);
    }

    final maxDistance = normalized.length < _shortWordLengthThreshold
        ? _maxDistanceForShortWord
        : _maxDistanceForLongWord;

    String? bestMatch;
    var bestDistance = maxDistance + 1;
    for (final entry in normalizedTerms.entries) {
      if ((entry.key.length - normalized.length).abs() > maxDistance) {
        continue;
      }
      final distance = _levenshtein(normalized, entry.key);
      if (distance < bestDistance) {
        bestDistance = distance;
        bestMatch = entry.value;
      }
    }

    if (bestMatch != null && bestDistance <= maxDistance) {
      return _preserveCase(word, bestMatch);
    }
    return word;
  }

  String _preserveCase(String original, String canonical) {
    final firstChar = original[0];
    if (firstChar == firstChar.toUpperCase() &&
        firstChar != firstChar.toLowerCase()) {
      return canonical[0].toUpperCase() + canonical.substring(1);
    }
    return canonical;
  }

  String _normalize(String input) {
    var result = input.toLowerCase();
    for (final entry in _accentReplacements.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    return result;
  }

  int _levenshtein(String a, String b) {
    if (a == b) {
      return 0;
    }
    if (a.isEmpty) {
      return b.length;
    }
    if (b.isEmpty) {
      return a.length;
    }

    var previousRow = List<int>.generate(b.length + 1, (i) => i);
    for (var i = 0; i < a.length; i++) {
      final currentRow = List<int>.filled(b.length + 1, 0);
      currentRow[0] = i + 1;
      for (var j = 0; j < b.length; j++) {
        final deletionCost = previousRow[j + 1] + 1;
        final insertionCost = currentRow[j] + 1;
        final substitutionCost = previousRow[j] + (a[i] == b[j] ? 0 : 1);
        currentRow[j + 1] = [
          deletionCost,
          insertionCost,
          substitutionCost,
        ].reduce((x, y) => x < y ? x : y);
      }
      previousRow = currentRow;
    }
    return previousRow[b.length];
  }
}
