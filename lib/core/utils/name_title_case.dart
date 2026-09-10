import 'package:characters/characters.dart';

/// Title-cases a person name for display (greeting, etc.).
///
/// Splits on whitespace and hyphens, uppercases the first grapheme of each
/// part, and lowercases the rest. Does not mutate stored profile data.
String nameTitleCase(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return '';

  final words = trimmed.split(RegExp(r'\s+'));
  return words.map(_titleCaseHyphenatedPart).join(' ');
}

String _titleCaseHyphenatedPart(String word) {
  return word.split('-').map(_titleCaseToken).join('-');
}

String _titleCaseToken(String token) {
  if (token.isEmpty) return token;
  final chars = token.characters;
  final first = chars.first.toUpperCase();
  final rest = chars.skip(1).toString().toLowerCase();
  return '$first$rest';
}
