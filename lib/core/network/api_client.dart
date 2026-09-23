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
    return _executeRequest(() => _dio.get<T>(path, queryParameters: queryParameters));
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _executeRequest(
      () => _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _executeRequest(
      () => _dio.put<T>(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _executeRequest(
      () => _dio.patch<T>(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _executeRequest(
      () => _dio.delete<T>(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<Response<T>> _executeRequest<T>(Future<Response<T>> Function() requestCall) async {
    try {
      return await requestCall();
    } on DioException catch (error) {
      if (error.error is Exception) {
        throw error.error as Exception;
      }
      throw NetworkException(error.message ?? 'Erreur reseau');
    }
  }
}
