import 'dart:math';

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
  static final RegExp _whitespaceOnly = RegExp(r'^\s+$');

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

  _MedicalTermLexicon? _lexicon;
  Future<_MedicalTermLexicon>? _lexiconInFlight;

  Future<void> warmUp() async {
    await _ensureLexicon();
  }

  Future<String> correct(String text) async {
    if (text.isEmpty) {
      return text;
    }

    final lexicon = await _ensureLexicon();
    if (lexicon.isEmpty) {
      return text;
    }

    return _correctWithLexicon(text, lexicon);
  }

  Future<_MedicalTermLexicon> _ensureLexicon() async {
    final cached = _lexicon;
    if (cached != null) {
      return cached;
    }

    final inFlight = _lexiconInFlight;
    if (inFlight != null) {
      return inFlight;
    }

    final future = _buildLexicon();
    _lexiconInFlight = future;
    try {
      final lexicon = await future;
      _lexicon = lexicon;
      return lexicon;
    } catch (_) {
      _lexiconInFlight = null;
      rethrow;
    }
  }

  Future<_MedicalTermLexicon> _buildLexicon() async {
    final dictionary = await _dictionary.load();
    final singleWords = <String, String>{};
    final phrasesByLength = <int, Map<String, String>>{};
    var maxPhraseLength = 1;

    for (final term in dictionary.knownTerms) {
      final tokens = _wordPattern
          .allMatches(term)
          .map((match) => match.group(0)!)
          .toList();
      if (tokens.isEmpty) {
        continue;
      }

      final normalizedKey = tokens.map(_normalize).join(' ');
      if (tokens.length == 1) {
        singleWords[normalizedKey] = term;
        continue;
      }

      phrasesByLength
          .putIfAbsent(tokens.length, () => <String, String>{})[normalizedKey] =
          term;
      if (tokens.length > maxPhraseLength) {
        maxPhraseLength = tokens.length;
      }
    }

    final immutablePhrases = <int, Map<String, String>>{
      for (final entry in phrasesByLength.entries)
        entry.key: Map<String, String>.unmodifiable(entry.value),
    };

    return _MedicalTermLexicon(
      singleWords: Map<String, String>.unmodifiable(singleWords),
      phrasesByLength: Map<int, Map<String, String>>.unmodifiable(
        immutablePhrases,
      ),
      maxPhraseLength: maxPhraseLength,
    );
  }

  String _correctWithLexicon(String text, _MedicalTermLexicon lexicon) {
    final matches = _wordPattern.allMatches(text).toList();
    if (matches.isEmpty) {
      return text;
    }

    final buffer = StringBuffer();
    var lastEnd = 0;
    var index = 0;

    while (index < matches.length) {
      final match = matches[index];
      buffer.write(text.substring(lastEnd, match.start));

      final maxN = min(lexicon.maxPhraseLength, matches.length - index);
      var corrected = false;

      for (var n = maxN; n >= 1; n--) {
        if (n > 1 && !_isWhitespaceSeparated(text, matches, index, n)) {
          continue;
        }

        final spanMatches = matches.sublist(index, index + n);
        final originalSpan = text.substring(
          spanMatches.first.start,
          spanMatches.last.end,
        );
        final normalizedSpan = spanMatches
            .map((m) => _normalize(m.group(0)!))
            .join(' ');

        final candidateMap = n == 1
            ? lexicon.singleWords
            : lexicon.phrasesByLength[n];
        if (candidateMap == null || candidateMap.isEmpty) {
          continue;
        }

        final correctedSpan = _correctNormalizedSpan(
          originalSpan,
          normalizedSpan,
          candidateMap,
        );
        if (correctedSpan != null) {
          buffer.write(correctedSpan);
          lastEnd = spanMatches.last.end;
          index += n;
          corrected = true;
          break;
        }
      }

      if (!corrected) {
        buffer.write(match.group(0)!);
        lastEnd = match.end;
        index += 1;
      }
    }

    buffer.write(text.substring(lastEnd));
    return buffer.toString();
  }

  bool _isWhitespaceSeparated(
    String text,
    List<RegExpMatch> matches,
    int startIndex,
    int n,
  ) {
    for (var i = startIndex; i < startIndex + n - 1; i++) {
      final between = text.substring(matches[i].end, matches[i + 1].start);
      if (!_whitespaceOnly.hasMatch(between)) {
        return false;
      }
    }
    return true;
  }

  String? _correctNormalizedSpan(
    String originalSpan,
    String normalizedSpan,
    Map<String, String> candidates,
  ) {
    final exact = candidates[normalizedSpan];
    if (exact != null) {
      return _preserveCase(originalSpan, exact);
    }

    final maxDistance = normalizedSpan.length < _shortWordLengthThreshold
        ? _maxDistanceForShortWord
        : _maxDistanceForLongWord;

    String? bestMatch;
    var bestDistance = maxDistance + 1;
    for (final entry in candidates.entries) {
      if ((entry.key.length - normalizedSpan.length).abs() > maxDistance) {
        continue;
      }
      final distance = _levenshtein(normalizedSpan, entry.key);
      if (distance < bestDistance) {
        bestDistance = distance;
        bestMatch = entry.value;
      }
    }

    if (bestMatch != null && bestDistance <= maxDistance) {
      return _preserveCase(originalSpan, bestMatch);
    }
    return null;
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
        currentRow[j + 1] = min(
          deletionCost,
          min(insertionCost, substitutionCost),
        );
      }
      previousRow = currentRow;
    }
    return previousRow[b.length];
  }
}

class _MedicalTermLexicon {
  const _MedicalTermLexicon({
    required this.singleWords,
    required this.phrasesByLength,
    required this.maxPhraseLength,
  });

  final Map<String, String> singleWords;
  final Map<int, Map<String, String>> phrasesByLength;
  final int maxPhraseLength;

  bool get isEmpty => singleWords.isEmpty && phrasesByLength.isEmpty;
}
