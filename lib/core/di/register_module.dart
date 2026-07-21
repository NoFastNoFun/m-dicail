import 'package:injectable/injectable.dart';
import 'package:medicail/core/network/interceptors/auth_interceptor.dart';
import 'package:medicail/core/network/interceptors/error_interceptor.dart';
import 'package:medicail/core/network/interceptors/logging_interceptor.dart';
import 'package:medicail/core/network/interceptors/token_refresh_interceptor.dart';
import 'package:medicail/core/config/app_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/router/app_router.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  Dio dio(
    AppConfig config,
    AuthInterceptor authInterceptor,
    LoggingInterceptor loggingInterceptor,
    ErrorInterceptor errorInterceptor,
    TokenRefreshInterceptor tokenRefreshInterceptor,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.addAll([
      authInterceptor,
      loggingInterceptor,
      errorInterceptor,
      tokenRefreshInterceptor,
    ]);
    tokenRefreshInterceptor.attachDio(dio);
    return dio;
  }

  @lazySingleton
  GoRouter goRouter(AppRouter appRouter) => appRouter.router;
}
