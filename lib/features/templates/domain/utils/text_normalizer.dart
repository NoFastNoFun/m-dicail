abstract final class TextNormalizer {
  static String normalize(String input) {
    final lower = input.toLowerCase();
    return lower
        .replaceAll(RegExp('[àáâãäå]'), 'a')
        .replaceAll(RegExp('[èéêë]'), 'e')
        .replaceAll(RegExp('[ìíîï]'), 'i')
        .replaceAll(RegExp('[òóôõö]'), 'o')
        .replaceAll(RegExp('[ùúûü]'), 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  }

  static int countKeywordMatches(String normalizedText, List<String> keywords) {
    var score = 0;
    for (final keyword in keywords) {
      final normalizedKeyword = normalize(keyword).trim();
      if (normalizedKeyword.isEmpty) {
        continue;
      }
      if (normalizedText.contains(normalizedKeyword)) {
        score += normalizedKeyword.split(RegExp(r'\s+')).length;
      }
    }
    return score;
  }
}
