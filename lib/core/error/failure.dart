import 'package:flutter/services.dart';
import 'package:medicail/core/error/exceptions.dart';

class Failure {
  const Failure(this.message);

  final String message;

  static Failure fromException(Object error) {
    if (error is ServerException) {
      return Failure(error.message);
    }
    if (error is NetworkException) {
      return Failure(error.message);
    }
    if (error is AudioException) {
      return Failure(error.message);
    }
    if (error is PlatformException) {
      return Failure(error.message ?? error.code);
    }
    if (error is StateError) {
      return Failure(error.message);
    }
    if (error is FormatException) {
      return Failure(error.message);
    }
    return Failure(error.toString());
  }
}
