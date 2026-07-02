class PunctuationHelper {
  /// Applique des heuristiques de ponctuation sur un texte reconnu
  static String applyHeuristics({
    required String text,
    String? wordPeriod,
    String? wordComma,
    List<String>? transitionWords,
  }) {
    if (text.trim().isEmpty) return text;

    String formatted = text;

    // 1. Remplacement des mots de ponctuation explicites
    final period = wordPeriod?.trim().isNotEmpty == true ? wordPeriod!.trim() : 'point';
    final comma = wordComma?.trim().isNotEmpty == true ? wordComma!.trim() : 'virgule';

    formatted = formatted.replaceAll(RegExp('\\b$period\\b', caseSensitive: false), '.');
    formatted = formatted.replaceAll(RegExp('\\b$comma\\b', caseSensitive: false), ',');

    // 2. Mots-clés de transition (insérer un point juste avant)
    final transitions = (transitionWords != null && transitionWords.isNotEmpty)
        ? transitionWords.map((t) => '\\b${RegExp.escape(t.trim())}\\b').toList()
        : [
            r"\ble patient\b",
            r"\bla patiente\b",
            r"\bà l'examen\b",
            r"\ba l'examen\b",
            r"\bau niveau\b",
            r"\bpour le traitement\b",
            r"\bpour la suite\b",
            r"\bmon diagnostic\b",
            r"\bensuite\b",
            r"\benfin\b",
          ];

    for (final t in transitions) {
      formatted = formatted.replaceAllMapped(
        RegExp('([^.!?])\\s+($t)', caseSensitive: false),
        (match) {
          final before = match.group(1)!;
          final word = match.group(2)!;
          final capitalizedWord = word[0].toUpperCase() + word.substring(1);
          return '$before. $capitalizedWord';
        },
      );
    }

    // 3. Majuscule après un point
    formatted = formatted.replaceAllMapped(
      RegExp(r'\.\s+([a-zà-ÿ])', caseSensitive: false),
      (match) {
        return '. ${match.group(1)!.toUpperCase()}';
      },
    );

    // 4. Nettoyage des espaces avant la ponctuation
    formatted = formatted.replaceAllMapped(RegExp(r'\s+([.,!?])'), (match) {
      return match.group(1)!;
    });

    return formatted;
  }
}
