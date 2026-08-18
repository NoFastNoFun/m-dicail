import 'package:injectable/injectable.dart';
import 'package:medicail/core/config/app_config.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:medicail/core/network/auth_token_storage.dart';
import 'package:medicail/features/recording/data/repositories/api_enhanced_transcription_repository.dart';
import 'package:medicail/features/recording/domain/repositories/enhanced_transcription_repository.dart';

@LazySingleton(as: EnhancedTranscriptionRepository)
class DynamicEnhancedTranscriptionRepository
    implements EnhancedTranscriptionRepository {
  DynamicEnhancedTranscriptionRepository(
    this._apiRepository,
    this._tokenStorage,
  );

  final ApiEnhancedTranscriptionRepository _apiRepository;
  final AuthTokenStorage _tokenStorage;

  @override
  Future<String> transcribeFile({
    required String filePath,
    required String sessionId,
    String language = 'fr',
  }) async {
    final token = await _tokenStorage.readToken();
    if (AppConfig.isOfflineMode(token)) {
      throw const NetworkException(
        'Transcription amelioree indisponible hors ligne',
      );
    }
    return _apiRepository.transcribeFile(
      filePath: filePath,
      sessionId: sessionId,
      language: language,
    );
  }
}
