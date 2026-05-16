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
    return const Failure('Une erreur est survenue');
  }
}
