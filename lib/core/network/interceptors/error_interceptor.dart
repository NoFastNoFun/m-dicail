import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:medicail/core/error/last_api_error_report.dart';

@lazySingleton
class ErrorInterceptor extends Interceptor {
  static const int _maxResponseBodyLength = 500;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final mapped = _mapException(err);
    _recordLastError(mapped, err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: mapped,
        message: err.message,
      ),
    );
  }

  void _recordLastError(Exception exception, DioException err) {
    final options = err.requestOptions;
    final method = options.method;
    final path = options.path;
    final statusCode = err.response?.statusCode;
    final message = switch (exception) {
      ServerException(:final message) => message,
      NetworkException(:final message) => message,
      _ => exception.toString(),
    };

    final lines = <String>[
      'message: $message',
      'uri: ${options.uri}',
      'baseUrl: ${options.baseUrl}',
      'method: $method',
      'path: $path',
      'dioType: ${err.type.name}',
    ];

    if (statusCode != null) {
      lines.add('status: $statusCode');
    }

    final dioMessage = err.message?.trim();
    if (dioMessage != null && dioMessage.isNotEmpty) {
      lines.add('dioMessage: $dioMessage');
    }

    final underlying = err.error;
    if (underlying != null && underlying != exception) {
      lines.add('underlying: $underlying');
    }

    lines
      ..add('build: ${kReleaseMode ? 'release' : 'debug'}')
      ..add('platform: ${defaultTargetPlatform.name}');

    final connectTimeout = options.connectTimeout;
    if (connectTimeout != null) {
      lines.add('connectTimeoutMs: ${connectTimeout.inMilliseconds}');
    }
    final receiveTimeout = options.receiveTimeout;
    if (receiveTimeout != null) {
      lines.add('receiveTimeoutMs: ${receiveTimeout.inMilliseconds}');
    }

    final responseBody = _truncateResponseBody(err.response?.data);
    if (responseBody != null) {
      lines.add('responseBody: $responseBody');
    }

    LastApiErrorReport.record(lines.join('\n'));
  }

  String? _truncateResponseBody(dynamic data) {
    if (data == null) return null;

    final text = data is String ? data : data.toString();
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;

    final lower = trimmed.toLowerCase();
    if (lower.startsWith('<html') ||
        lower.startsWith('<!doctype') ||
        lower.contains('<body')) {
      return null;
    }

    if (trimmed.length > _maxResponseBodyLength) {
      return '${trimmed.substring(0, _maxResponseBodyLength)}...';
    }
    return trimmed;
  }

  Exception _mapException(DioException err) {
    final method = err.requestOptions.method;
    final path = err.requestOptions.path;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        return NetworkException(
          'Problème de connexion',
          method: method,
          path: path,
        );
      case DioExceptionType.cancel:
        return NetworkException(
          'Requete annulee',
          method: method,
          path: path,
        );
      case DioExceptionType.badResponse:
        return _mapResponseException(err, method: method, path: path);
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return NetworkException(
          err.message ?? 'Erreur reseau inconnue',
          method: method,
          path: path,
          statusCode: err.response?.statusCode,
        );
    }
  }

  ServerException _mapResponseException(
    DioException err, {
    required String method,
    required String path,
  }) {
    final statusCode = err.response?.statusCode;
    final extracted = _extractMessage(err.response?.data);

    if (statusCode != null && statusCode >= 500) {
      return ServerException(
        'Le service est temporairement indisponible (Erreur $statusCode)',
        statusCode: statusCode,
        method: method,
        path: path,
      );
    }

    final message = extracted ?? err.message ?? 'Erreur serveur';

    if (statusCode == 401) {
      return ServerException(
        extracted ?? 'Email ou mot de passe incorrect',
        statusCode: statusCode,
        method: method,
        path: path,
      );
    }
    if (statusCode == 403) {
      return ServerException(
        extracted ?? 'Non autorise',
        statusCode: statusCode,
        method: method,
        path: path,
      );
    }
    return ServerException(
      message,
      statusCode: statusCode,
      method: method,
      path: path,
    );
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
      if (message is List && message.isNotEmpty) {
        return message.map((e) => e.toString()).join(', ');
      }
    }
    if (data is String && data.isNotEmpty) {
      final text = data.trim().toLowerCase();
      if (text.startsWith('<html') ||
          text.startsWith('<!doctype') ||
          text.contains('<body')) {
        return null;
      }
      if (data.length > 150) {
        return null;
      }
      return data;
    }
    return null;
  }
}
