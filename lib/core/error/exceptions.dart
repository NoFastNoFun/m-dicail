class ServerException implements Exception {
  const ServerException(
    this.message, {
    this.statusCode,
    this.method,
    this.path,
  });

  final String message;
  final int? statusCode;
  final String? method;
  final String? path;

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class NetworkException implements Exception {
  const NetworkException(
    this.message, {
    this.method,
    this.path,
    this.statusCode,
  });

  final String message;
  final String? method;
  final String? path;
  final int? statusCode;

  @override
  String toString() => 'NetworkException: $message';
}

class AudioException implements Exception {
  const AudioException(this.message);

  final String message;

  @override
  String toString() => 'AudioException: $message';
}
