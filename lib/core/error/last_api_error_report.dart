/// Holds the last API error report text for error-toast copy / report actions.
class LastApiErrorReport {
  LastApiErrorReport._();

  static String? _details;

  static String? get details => _details;

  static void record(String details) {
    _details = details;
  }

  static void clear() {
    _details = null;
  }

  static String buildClipboardText({
    required String message,
    String? details,
  }) {
    final buffer = StringBuffer()
      ..writeln('Message: $message')
      ..writeln('Time: ${DateTime.now().toIso8601String()}');

    final extra = details?.trim();
    if (extra != null && extra.isNotEmpty) {
      buffer
        ..writeln('Details:')
        ..writeln(extra);
    }

    return buffer.toString().trimRight();
  }
}
