import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class LoggingInterceptor extends Interceptor {
  static const int _maxBodyLength = 500;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[HTTP] --> ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      final body = response.data?.toString() ?? '';
      final truncated = body.length > _maxBodyLength
          ? '${body.substring(0, _maxBodyLength)}...'
          : body;
      debugPrint(
        '[HTTP] <-- ${response.statusCode} ${response.requestOptions.uri} $truncated',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '[HTTP] xx ${err.requestOptions.method} ${err.requestOptions.uri} ${err.message}',
      );
    }
    handler.next(err);
  }
}
