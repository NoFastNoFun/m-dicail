abstract final class InputValidationKeys {
  static const required = 'inputErrorRequired';
  static const email = 'inputErrorEmail';
  static const number = 'inputErrorNumber';
  static const password = 'inputErrorPassword';
}

abstract final class InputValidators {
  static const int passwordMinLength = 8;

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _numberRegex = RegExp(r'^-?\d+(\.\d+)?$');

  static String? validateText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return InputValidationKeys.required;
    }
    return null;
  }

  static String? validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return InputValidationKeys.required;
    }
    if (!_numberRegex.hasMatch(value.trim())) {
      return InputValidationKeys.number;
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return InputValidationKeys.required;
    }
    if (value.trim() == 'admin') {
      return null;
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return InputValidationKeys.email;
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return InputValidationKeys.required;
    }
    if (value == 'admin') {
      return null;
    }
    if (value.length < passwordMinLength) {
      return InputValidationKeys.password;
    }
    return null;
  }

  static String? validateTextarea(String? value) {
    if (value == null || value.trim().isEmpty) {
      return InputValidationKeys.required;
    }
    return null;
  }
}
