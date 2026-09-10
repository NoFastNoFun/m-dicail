import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/utils/transcript_word_diff.dart';

void main() {
  group('TranscriptWordDiff.normalizeKey', () {
    test('lowercases for matching', () {
      expect(TranscriptWordDiff.normalizeKey('Douleur'), 'douleur');
    });

    test('strips trailing punctuation', () {
      expect(TranscriptWordDiff.normalizeKey('patient.'), 'patient');
      expect(TranscriptWordDiff.normalizeKey('patient,'), 'patient');
      expect(TranscriptWordDiff.normalizeKey('patient!'), 'patient');
    });

    test('keeps hyphens in medical compounds', () {
      expect(
        TranscriptWordDiff.normalizeKey('anti-inflammatoire'),
        'anti-inflammatoire',
      );
      expect(TranscriptWordDiff.normalizeKey('L4-L5'), 'l4-l5');
    });

    test('treats unicode dashes as hyphen', () {
      expect(TranscriptWordDiff.normalizeKey('L4–L5'), 'l4-l5');
      expect(TranscriptWordDiff.normalizeKey('anti‑inflammatoire'), 'anti-inflammatoire');
    });

    test('strips apostrophes and other punctuation', () {
      // Accents stay; only the apostrophe is removed.
      expect(TranscriptWordDiff.normalizeKey("l'épaule"), 'lépaule');
      expect(TranscriptWordDiff.normalizeKey('lépaule'), 'lépaule');
    });

    test('keeps accents as significant', () {
      expect(TranscriptWordDiff.normalizeKey('épaule'), 'épaule');
      expect(TranscriptWordDiff.normalizeKey('epaule'), 'epaule');
      expect(
        TranscriptWordDiff.normalizeKey('épaule'),
        isNot(TranscriptWordDiff.normalizeKey('epaule')),
      );
    });
  });

  group('TranscriptWordDiff.compare', () {
    test('identical texts produce no highlights', () {
      final result = TranscriptWordDiff.compare(
        'Douleur au genou.',
        'Douleur au genou.',
      );
      expect(result.left.every((s) => !s.isDifferent), isTrue);
      expect(result.right.every((s) => !s.isDifferent), isTrue);
    });

    test('ignores case differences', () {
      final result = TranscriptWordDiff.compare('Douleur', 'douleur');
      expect(result.left.single.isDifferent, isFalse);
      expect(result.right.single.isDifferent, isFalse);
    });

    test('ignores trailing punctuation differences', () {
      final result = TranscriptWordDiff.compare('patient.', 'patient');
      expect(result.left.single.isDifferent, isFalse);
      expect(result.right.single.isDifferent, isFalse);
      expect(result.left.single.text, 'patient.');
      expect(result.right.single.text, 'patient');
    });

    test('matches hyphenated medical terms across case', () {
      final result = TranscriptWordDiff.compare(
        'anti-inflammatoire',
        'Anti-inflammatoire',
      );
      expect(result.left.single.isDifferent, isFalse);
      expect(result.right.single.isDifferent, isFalse);
    });

    test('matches unicode dash to ASCII hyphen', () {
      final result = TranscriptWordDiff.compare('L4–L5', 'L4-L5');
      expect(result.left.single.isDifferent, isFalse);
      expect(result.right.single.isDifferent, isFalse);
    });

    test('matches after stripping apostrophe', () {
      final result = TranscriptWordDiff.compare("l'épaule", 'lépaule');
      expect(result.left.single.isDifferent, isFalse);
      expect(result.right.single.isDifferent, isFalse);
    });

    test('highlights accent mismatch', () {
      final result = TranscriptWordDiff.compare('épaule', 'epaule');
      expect(result.left.single.isDifferent, isTrue);
      expect(result.right.single.isDifferent, isTrue);
    });

    test('highlights replacement', () {
      final result = TranscriptWordDiff.compare(
        'douleur genou droit',
        'douleur hanche droit',
      );
      expect(
        result.left.where((s) => !s.isWhitespaceSpan).map((s) => s.isDifferent),
        [false, true, false],
      );
      expect(
        result.right
            .where((s) => !s.isWhitespaceSpan)
            .map((s) => s.isDifferent),
        [false, true, false],
      );
    });

    test('highlights insert on the right', () {
      final result = TranscriptWordDiff.compare(
        'douleur genou',
        'douleur genou droit',
      );
      final rightWords =
          result.right.where((s) => !s.isWhitespaceSpan).toList();
      expect(rightWords.map((s) => s.isDifferent), [false, false, true]);
      expect(
        result.left.where((s) => !s.isWhitespaceSpan).every((s) => !s.isDifferent),
        isTrue,
      );
    });

    test('highlights delete on the left', () {
      final result = TranscriptWordDiff.compare(
        'douleur genou droit',
        'douleur genou',
      );
      final leftWords = result.left.where((s) => !s.isWhitespaceSpan).toList();
      expect(leftWords.map((s) => s.isDifferent), [false, false, true]);
      expect(
        result.right
            .where((s) => !s.isWhitespaceSpan)
            .every((s) => !s.isDifferent),
        isTrue,
      );
    });

    test('preserves whitespace and does not highlight it', () {
      final result = TranscriptWordDiff.compare(
        'a\n\nb',
        'a\n\nc',
      );
      expect(result.left.length, 3);
      expect(result.left[1].text, '\n\n');
      expect(result.left[1].isDifferent, isFalse);
      expect(result.left[0].isDifferent, isFalse);
      expect(result.left[2].isDifferent, isTrue);
      expect(result.right[2].isDifferent, isTrue);
    });

    test('reconstructs original text from spans', () {
      const left = 'Patient. Douleur L4-L5.';
      const right = 'patient douleur L4–L5';
      final result = TranscriptWordDiff.compare(left, right);
      expect(result.left.map((s) => s.text).join(), left);
      expect(result.right.map((s) => s.text).join(), right);
    });
  });
}

extension on TranscriptDiffSpan {
  bool get isWhitespaceSpan => text.trim().isEmpty;
}
