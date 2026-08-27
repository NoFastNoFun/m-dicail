import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    
    if (newText.length < oldValue.text.length) {
      return newValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      if (RegExp(r'[0-9]').hasMatch(newText[i])) {
        buffer.write(newText[i]);
      }
    }

    final rawText = buffer.toString();
    if (rawText.length > 8) {
      return oldValue;
    }

    final formattedText = StringBuffer();
    for (int i = 0; i < rawText.length; i++) {
      if (i == 2 || i == 4) {
        formattedText.write('/');
      }
      formattedText.write(rawText[i]);
    }

    final stringFormatted = formattedText.toString();
    
    int newSelection = stringFormatted.length;
    if (newValue.selection.end < newText.length) {
      newSelection = newValue.selection.end;
    }

    return TextEditingValue(
      text: stringFormatted,
      selection: TextSelection.collapsed(offset: newSelection),
    );
  }
}
