import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/config/app_config.dart';
import 'package:medicail/core/error/exceptions.dart';

typedef AuthTokens = ({String accessToken, String refreshToken});

@lazySingleton
class AuthTokenRefreshClient {
  AuthTokenRefreshClient(AppConfig config) : _dio = _createDio(config);

  final Dio _dio;

  static Dio _createDio(AppConfig config) {
    return Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  Future<AuthTokens> refresh(String refreshToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = response.data;
      if (data == null ||
          data['accessToken'] == null ||
          data['refreshToken'] == null) {
        throw const ServerException(
          'Reponse de refresh invalide.',
          statusCode: 401,
        );
      }
      return (
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        throw const ServerException(
          'Session expiree.',
          statusCode: 401,
        );
      }
      throw NetworkException(error.message ?? 'Erreur reseau');
    }
  }
}
