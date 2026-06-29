import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/utils/transcript_merge_helper.dart';

void main() {
  group('TranscriptMergeHelper', () {
    test('returns segment when base is empty', () {
      expect(TranscriptMergeHelper.merge('', 'bonjour'), 'bonjour');
    });

    test('returns base when segment is empty', () {
      expect(TranscriptMergeHelper.merge('bonjour', ''), 'bonjour');
    });

    test('uses cumulative segment when it starts with base', () {
      expect(
        TranscriptMergeHelper.merge('bonjour', 'bonjour docteur'),
        'bonjour docteur',
      );
    });

    test('avoids duplicate when segment is already at end of base', () {
      expect(
        TranscriptMergeHelper.merge('bonjour docteur', 'docteur'),
        'bonjour docteur',
      );
    });

    test('joins prior transcript with a new listening segment', () {
      expect(
        TranscriptMergeHelper.merge('premiere phrase', 'deuxieme phrase'),
        'premiere phrase deuxieme phrase',
      );
    });

    test('merges overlapping segments after speech engine restart', () {
      expect(
        TranscriptMergeHelper.merge('bonjour monsieur', 'monsieur le patient'),
        'bonjour monsieur le patient',
      );
    });
  });
}
