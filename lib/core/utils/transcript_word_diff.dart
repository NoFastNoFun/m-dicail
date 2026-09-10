/// A span of original transcript text with a difference flag for highlighting.
final class TranscriptDiffSpan {
  const TranscriptDiffSpan({
    required this.text,
    required this.isDifferent,
  });

  final String text;
  final bool isDifferent;
}

final class TranscriptWordDiffResult {
  const TranscriptWordDiffResult({
    required this.left,
    required this.right,
  });

  final List<TranscriptDiffSpan> left;
  final List<TranscriptDiffSpan> right;
}

/// Word-level diff for AI vs local transcript comparison.
///
/// Matching ignores case and punctuation except hyphens (including unicode
/// dashes normalized to `-`). Accents remain significant. Original casing and
/// punctuation are preserved in the returned spans.
abstract final class TranscriptWordDiff {
  static final RegExp _whitespaceSplit = RegExp(r'(\s+)');
  static final RegExp _unicodeDashes = RegExp(r'[\u2010\u2011\u2012\u2013\u2014\u2212]');
  static final RegExp _stripPunctuation = RegExp(
    r'[^\p{L}\p{N}\-]',
    unicode: true,
  );

  static TranscriptWordDiffResult compare(String left, String right) {
    final leftParts = _tokenize(left);
    final rightParts = _tokenize(right);

    final leftWords = <_WordToken>[];
    final rightWords = <_WordToken>[];
    for (final part in leftParts) {
      if (!part.isWhitespace) leftWords.add(part);
    }
    for (final part in rightParts) {
      if (!part.isWhitespace) rightWords.add(part);
    }

    final leftKeys = leftWords.map((w) => w.key).toList(growable: false);
    final rightKeys = rightWords.map((w) => w.key).toList(growable: false);
    final matched = _lcsMatchMask(leftKeys, rightKeys);

    var leftWordIndex = 0;
    var rightWordIndex = 0;
    final leftSpans = <TranscriptDiffSpan>[];
    final rightSpans = <TranscriptDiffSpan>[];

    for (final part in leftParts) {
      if (part.isWhitespace) {
        leftSpans.add(TranscriptDiffSpan(text: part.text, isDifferent: false));
        continue;
      }
      leftSpans.add(
        TranscriptDiffSpan(
          text: part.text,
          isDifferent: !matched.leftMatched[leftWordIndex],
        ),
      );
      leftWordIndex++;
    }

    for (final part in rightParts) {
      if (part.isWhitespace) {
        rightSpans.add(
          TranscriptDiffSpan(text: part.text, isDifferent: false),
        );
        continue;
      }
      rightSpans.add(
        TranscriptDiffSpan(
          text: part.text,
          isDifferent: !matched.rightMatched[rightWordIndex],
        ),
      );
      rightWordIndex++;
    }

    return TranscriptWordDiffResult(left: leftSpans, right: rightSpans);
  }

  /// Normalization used only for equality checks.
  static String normalizeKey(String token) {
    final lowered = token.toLowerCase();
    final withHyphens = lowered.replaceAll(_unicodeDashes, '-');
    return withHyphens.replaceAll(_stripPunctuation, '');
  }

  static List<_WordToken> _tokenize(String text) {
    if (text.isEmpty) return const [];

    final parts = <_WordToken>[];
    var start = 0;
    for (final match in _whitespaceSplit.allMatches(text)) {
      if (match.start > start) {
        final word = text.substring(start, match.start);
        parts.add(
          _WordToken(
            text: word,
            key: normalizeKey(word),
            isWhitespace: false,
          ),
        );
      }
      parts.add(
        _WordToken(
          text: match.group(0)!,
          key: '',
          isWhitespace: true,
        ),
      );
      start = match.end;
    }
    if (start < text.length) {
      final word = text.substring(start);
      parts.add(
        _WordToken(
          text: word,
          key: normalizeKey(word),
          isWhitespace: false,
        ),
      );
    }
    return parts;
  }

  /// Classic LCS DP; returns which word indices participate in the LCS.
  static _MatchMask _lcsMatchMask(List<String> left, List<String> right) {
    final m = left.length;
    final n = right.length;
    final leftMatched = List<bool>.filled(m, false);
    final rightMatched = List<bool>.filled(n, false);
    if (m == 0 || n == 0) {
      return _MatchMask(leftMatched: leftMatched, rightMatched: rightMatched);
    }

    final dp = List.generate(m + 1, (_) => List<int>.filled(n + 1, 0));
    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        if (left[i - 1] == right[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          final up = dp[i - 1][j];
          final leftCell = dp[i][j - 1];
          dp[i][j] = up >= leftCell ? up : leftCell;
        }
      }
    }

    var i = m;
    var j = n;
    while (i > 0 && j > 0) {
      if (left[i - 1] == right[j - 1]) {
        leftMatched[i - 1] = true;
        rightMatched[j - 1] = true;
        i--;
        j--;
      } else if (dp[i - 1][j] >= dp[i][j - 1]) {
        i--;
      } else {
        j--;
      }
    }

    return _MatchMask(leftMatched: leftMatched, rightMatched: rightMatched);
  }
}

final class _WordToken {
  const _WordToken({
    required this.text,
    required this.key,
    required this.isWhitespace,
  });

  final String text;
  final String key;
  final bool isWhitespace;
}

final class _MatchMask {
  const _MatchMask({
    required this.leftMatched,
    required this.rightMatched,
  });

  final List<bool> leftMatched;
  final List<bool> rightMatched;
}
