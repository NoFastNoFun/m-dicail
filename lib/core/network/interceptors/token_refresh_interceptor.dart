import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/auth/auth_session_coordinator.dart';
import 'package:medicail/core/config/app_config.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:medicail/core/network/auth_token_refresh_client.dart';
import 'package:medicail/core/network/auth_token_storage.dart';

@lazySingleton
class TokenRefreshInterceptor extends QueuedInterceptor {
  TokenRefreshInterceptor(
    this._tokenStorage,
    this._refreshClient,
    this._sessionCoordinator,
  );

  static const _skipRefreshPaths = {
    '/auth/login',
    '/auth/register',
    '/auth/refresh',
    '/auth/logout',
  };

  final AuthTokenStorage _tokenStorage;
  final AuthTokenRefreshClient _refreshClient;
  final AuthSessionCoordinator _sessionCoordinator;

  Dio? _dio;

  void attachDio(Dio dio) {
    _dio = dio;
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldAttemptRefresh(err)) {
      handler.next(err);
      return;
    }

    if (await _isMockAdminToken()) {
      handler.next(err);
      return;
    }

    final dio = _dio;
    if (dio == null) {
      handler.next(err);
      return;
    }

    try {
      final refreshToken = await _tokenStorage.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _sessionCoordinator.expireSession();
        handler.next(err);
        return;
      }

      final tokens = await _refreshClient.refresh(refreshToken);
      await _tokenStorage.writeTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      final requestOptions = err.requestOptions;
      requestOptions.headers['Authorization'] =
          'Bearer ${tokens.accessToken}';
      requestOptions.extra['retriedAfterRefresh'] = true;

      final response = await dio.fetch<dynamic>(requestOptions);
      handler.resolve(response);
    } on ServerException catch (error) {
      if (error.statusCode == 401) {
        await _sessionCoordinator.expireSession();
      }
      handler.next(err);
    } catch (_) {
      handler.next(err);
    }
  }

  bool _shouldAttemptRefresh(DioException err) {
    if (err.response?.statusCode != 401) {
      return false;
    }

    final path = err.requestOptions.path;
    if (_skipRefreshPaths.contains(path)) {
      return false;
    }

    final extra = err.requestOptions.extra;
    if (extra['skipTokenRefresh'] == true || extra['retriedAfterRefresh'] == true) {
      return false;
    }

    return true;
  }

  Future<bool> _isMockAdminToken() async {
    final token = await _tokenStorage.readToken();
    return token == AppConfig.mockAdminToken;
  }
}
