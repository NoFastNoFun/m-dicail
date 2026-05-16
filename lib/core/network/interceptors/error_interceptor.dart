import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/error/exceptions.dart';

@lazySingleton
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: _mapException(err),
        message: err.message,
      ),
    );
  }

  Exception _mapException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException('Probleme de connexion');
      case DioExceptionType.cancel:
        return const NetworkException('Requete annulee');
      case DioExceptionType.badResponse:
        return _mapResponseException(err);
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return NetworkException(err.message ?? 'Erreur reseau inconnue');
    }
  }

  ServerException _mapResponseException(DioException err) {
    final statusCode = err.response?.statusCode;
    final message = _extractMessage(err.response?.data) ??
        err.message ??
        'Erreur serveur';

    if (statusCode != null && statusCode >= 500) {
      return ServerException(message, statusCode: statusCode);
    }
    if (statusCode == 401 || statusCode == 403) {
      return ServerException('Non autorise', statusCode: statusCode);
    }
    return ServerException(message, statusCode: statusCode);
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String) {
        return detail;
      }
      final message = data['message'];
      if (message is String) {
        return message;
      }
    }
    if (data is String && data.isNotEmpty) {
      return data;
    }
    return null;
  }
}
