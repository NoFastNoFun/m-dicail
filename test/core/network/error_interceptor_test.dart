import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:medicail/core/error/last_api_error_report.dart';
import 'package:medicail/core/network/interceptors/error_interceptor.dart';

class _CapturingErrorHandler extends ErrorInterceptorHandler {
  DioException? rejected;

  @override
  void reject(
    DioException error, [
    bool callFollowingErrorInterceptor = false,
  ]) {
    rejected = error;
  }
}

void main() {
  late ErrorInterceptor interceptor;

  setUp(() {
    interceptor = ErrorInterceptor();
    LastApiErrorReport.clear();
  });

  tearDown(LastApiErrorReport.clear);

  test('records uri, dioType and underlying message on connectionError', () {
    final options = RequestOptions(
      path: '/auth/forgot-password',
      method: 'POST',
      baseUrl: 'http://10.10.161.239/api/v1',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    );
    final underlying = const SocketException(
      "Failed host lookup: '10.10.161.239'",
    );
    final err = DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
      message: "The connection errored: Failed host lookup: '10.10.161.239'",
      error: underlying,
    );
    final handler = _CapturingErrorHandler();

    interceptor.onError(err, handler);

    final details = LastApiErrorReport.details;
    expect(details, isNotNull);
    expect(details, contains('uri: http://10.10.161.239/api/v1/auth/forgot-password'));
    expect(details, contains('baseUrl: http://10.10.161.239/api/v1'));
    expect(details, contains('method: POST'));
    expect(details, contains('path: /auth/forgot-password'));
    expect(details, contains('dioType: connectionError'));
    expect(
      details,
      contains(
        "dioMessage: The connection errored: Failed host lookup: '10.10.161.239'",
      ),
    );
    expect(details, contains("underlying: SocketException: Failed host lookup: '10.10.161.239'"));
    expect(details, contains('connectTimeoutMs: 15000'));
    expect(details, contains('receiveTimeoutMs: 30000'));
    expect(details, contains('build:'));
    expect(details, contains('platform:'));

    final mapped = handler.rejected?.error;
    expect(mapped, isA<NetworkException>());
    expect((mapped as NetworkException).message, 'Problème de connexion');
  });
}
