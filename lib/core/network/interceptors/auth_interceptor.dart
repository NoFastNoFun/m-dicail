import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/network/auth_token_storage.dart';

@lazySingleton
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage);

  final AuthTokenStorage _tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _tokenStorage.readToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // Corrupted secure storage must not block unauthenticated calls (login).
    }
    handler.next(options);
  }
}
