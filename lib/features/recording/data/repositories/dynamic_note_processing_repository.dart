import 'package:injectable/injectable.dart';
import 'package:medicail/core/config/app_config.dart';
import 'package:medicail/core/network/auth_token_storage.dart';
import 'package:medicail/features/recording/data/repositories/api_note_processing_repository.dart';
import 'package:medicail/features/recording/data/repositories/api_ai_note_processing_repository.dart';
import 'package:medicail/features/settings/domain/repositories/user_preferences_repository.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';
import 'package:medicail/features/recording/domain/repositories/note_processing_repository.dart';

@LazySingleton(as: NoteProcessingRepository)
class DynamicNoteProcessingRepository implements NoteProcessingRepository {
  DynamicNoteProcessingRepository(
    this._apiRepository,
    this._tokenStorage,
    this._aiRepository,
    this._preferences,
  );

  final ApiNoteProcessingRepository _apiRepository;
  final AuthTokenStorage _tokenStorage;
  final ApiAiNoteProcessingRepository _aiRepository;
  final UserPreferencesRepository _preferences;

  @override
  Future<SoapNoteResult> process({
    required String sessionId,
    required String rawText,
    required String language,
  }) async {
    final token = await _tokenStorage.readToken();
    if (AppConfig.isOfflineMode(token)) {
      return SoapNoteResult(processedText: rawText, soapNote: const SoapNote());
    }
    final useAi = await _preferences.readAiEnhanceEnabled();
    final NoteProcessingRepository repository = useAi
        ? _aiRepository
        : _apiRepository;
    return repository.process(
      sessionId: sessionId,
      rawText: rawText,
      language: language,
    );
  }
}
