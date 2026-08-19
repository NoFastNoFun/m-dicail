import 'package:injectable/injectable.dart';
import 'package:medicail/core/config/app_config.dart';
import 'package:medicail/core/network/auth_token_storage.dart';
import 'package:medicail/features/medical_watch/data/repositories/api_medical_watch_repository.dart';
import 'package:medicail/features/medical_watch/data/repositories/secure_storage_medical_watch_repository.dart';
import 'package:medicail/features/medical_watch/domain/entities/medical_watch_article.dart';
import 'package:medicail/features/medical_watch/domain/enums/medical_watch_specialty.dart';
import 'package:medicail/features/medical_watch/domain/repositories/medical_watch_repository.dart';

@LazySingleton(as: MedicalWatchRepository)
class DynamicMedicalWatchRepository implements MedicalWatchRepository {
  DynamicMedicalWatchRepository(
    this._apiRepository,
    this._localRepository,
    this._tokenStorage,
  );

  final ApiMedicalWatchRepository _apiRepository;
  final SecureStorageMedicalWatchRepository _localRepository;
  final AuthTokenStorage _tokenStorage;

  Future<bool> _isOffline() async {
    final token = await _tokenStorage.readToken();
    return AppConfig.isOfflineMode(token);
  }

  @override
  Future<List<MedicalWatchArticle>> getArticles({
    MedicalWatchSpecialty? specialty,
    int? limit,
  }) async {
    if (await _isOffline()) {
      return _localRepository.getArticles(specialty: specialty, limit: limit);
    }

    final articles = await _apiRepository.getArticles(
      specialty: specialty,
      limit: limit,
    );

    // Met en cache les articles pour accès hors-ligne ultérieur.
    await _localRepository.cacheArticles(articles);

    return articles;
  }

  @override
  Future<List<MedicalWatchArticle>> searchPubmed(
    String query, {
    int maxResults = 10,
  }) async {
    if (await _isOffline()) {
      return _localRepository.searchPubmed(query, maxResults: maxResults);
    }
    return _apiRepository.searchPubmed(query, maxResults: maxResults);
  }

  @override
  Future<void> triggerSync() async {
    if (await _isOffline()) return;
    await _apiRepository.triggerSync();
  }
}
