import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/config/app_config.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:medicail/features/recording/domain/repositories/enhanced_transcription_repository.dart';

@injectable
class ApiEnhancedTranscriptionRepository
    implements EnhancedTranscriptionRepository {
  ApiEnhancedTranscriptionRepository(this._dio, this._config);

  final Dio _dio;
  final AppConfig _config;

  @override
  Future<String> transcribeFile({
    required String filePath,
    required String sessionId,
    String language = 'fr',
  }) async {
    final fileName = filePath.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
      'language': language,
      'session_id': sessionId,
    });

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '${_config.aiBaseUrl}/transcriptions',
        data: formData,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          sendTimeout: _config.enhanceUploadTimeout,
          receiveTimeout: _config.enhanceReceiveTimeout,
        ),
      );

      final data = response.data;
      final text = data?['text'] as String?;
      if (text == null) {
        throw const ServerException('Reponse de transcription invalide');
      }
      return text.trim();
    } on DioException catch (error) {
      if (error.error is Exception) {
        throw error.error as Exception;
      }
      throw NetworkException(error.message ?? 'Erreur reseau');
    }
  }
}
