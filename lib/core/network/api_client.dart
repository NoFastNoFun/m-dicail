import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/error/exceptions.dart';

@lazySingleton
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _request(() => _dio.get<T>(path, queryParameters: queryParameters));
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _request(
      () => _dio.post<T>(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _request(
      () => _dio.put<T>(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _request(
      () => _dio.delete<T>(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<Response<T>> _request<T>(Future<Response<T>> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      if (error.response != null) {
        final statusCode = error.response!.statusCode;
        final data = error.response!.data;

        if (statusCode == 422 && data is Map<String, dynamic>) {
          if (data['detail'] is List && data['detail'].isNotEmpty) {
            final firstError = data['detail'][0];
            if (firstError is Map && firstError.containsKey('msg')) {
              throw ServerException(firstError['msg'] as String);
            }
          }
        }

        if (statusCode == 429 && data is Map<String, dynamic>) {
          if (data.containsKey('error')) {
            throw ServerException("Trop de requêtes : veuillez patienter.");
          }
        }

        if (data is Map<String, dynamic> &&
            data.containsKey('detail') &&
            data['detail'] is String) {
          throw ServerException(data['detail'] as String);
        }
      }

      if (error.error is Exception) {
        throw error.error as Exception;
      }
      throw NetworkException(error.message ?? 'Erreur réseau');
    }
  }
}
