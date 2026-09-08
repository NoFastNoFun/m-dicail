import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/audio/audio_compression_service.dart';
import 'package:medicail/core/config/app_config.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:medicail/features/recording/domain/repositories/enhanced_transcription_repository.dart';

@injectable
class ApiEnhancedTranscriptionRepository
    implements EnhancedTranscriptionRepository {
  ApiEnhancedTranscriptionRepository(
    this._dio,
    this._config,
    this._compression,
  );

  final Dio _dio;
  final AppConfig _config;
  final AudioCompressionService _compression;

  @override
  Future<String> transcribeFile({
    required String filePath,
    required String sessionId,
    String language = 'fr',
  }) async {
    final upload = await _compression.prepareUpload(filePath);
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          upload.path,
          filename: upload.path.replaceAll('\\', '/').split('/').last,
          contentType: DioMediaType.parse(upload.mimeType),
        ),
        'language': language,
        'session_id': sessionId,
      });
      final base = _config.aiBaseUrl.replaceAll(RegExp(r'/+$'), '');
      if (kDebugMode) {
        debugPrint(
          '[AiUpload] type=${upload.mimeType}; '
          'bytes=${formData.files.single.value.length}',
        );
      }
      final response = await _dio.post<Map<String, dynamic>>(
        '$base/transcriptions',
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
      if (kDebugMode) {
        debugPrint('[AiUpload] HTTP ${response.statusCode}; transcription received');
      }
      return text.trim();
    } on DioException catch (error) {
      if (error.error is Exception) {
        throw error.error as Exception;
      }
      throw NetworkException(error.message ?? 'Erreur reseau');
    } finally {
      await upload.dispose();
    }
  }
}
