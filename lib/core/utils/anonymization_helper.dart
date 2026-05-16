abstract final class AnonymizationHelper {
  static const String _replacement = '[ANONYMIZED]';

  static final RegExp _nirPattern = RegExp(
    r'\b[12]\s?\d{2}\s?\d{2}\s?\d{2}\s?\d{3}\s?\d{3}\s?\d{2}\b',
  );

  static final RegExp _isoDatePattern = RegExp(
    r'\b\d{4}[-/]\d{2}[-/]\d{2}\b',
  );

  static final RegExp _frDatePattern = RegExp(
    r'\b\d{1,2}[-/]\d{1,2}[-/]\d{2,4}\b',
  );

  static final RegExp _phonePattern = RegExp(
    r'(?:\+33|0)\s?[1-9](?:[\s.-]?\d{2}){4}',
  );

  static final RegExp _emailPattern = RegExp(
    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b',
  );

  static String anonymize(String input) {
    if (input.isEmpty) {
      return input;
    }

    var result = input;
    result = result.replaceAll(_nirPattern, _replacement);
    result = result.replaceAll(_isoDatePattern, _replacement);
    result = result.replaceAll(_frDatePattern, _replacement);
    result = result.replaceAll(_phonePattern, _replacement);
    result = result.replaceAll(_emailPattern, _replacement);
    return result;
  }
}
