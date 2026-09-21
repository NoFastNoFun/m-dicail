import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/storage/secure_collection_store.dart';
import 'package:medicail/features/medical_watch/data/models/medical_watch_article_model.dart';
import 'package:medicail/features/medical_watch/domain/entities/medical_watch_article.dart';
import 'package:medicail/features/medical_watch/domain/enums/medical_watch_specialty.dart';
import 'package:medicail/features/medical_watch/domain/repositories/medical_watch_repository.dart';

@injectable
class SecureStorageMedicalWatchRepository implements MedicalWatchRepository {
  SecureStorageMedicalWatchRepository(this._storage) {
    _store = SecureCollectionStore<MedicalWatchArticle>(
      storage: _storage,
      key: _articlesKey,
      fromJson: MedicalWatchArticleModel.fromJson,
      toJson: (article) =>
          MedicalWatchArticleModel.fromEntity(article).toJson(),
    );
  }

  static const String _articlesKey = 'medical_watch_articles_v1';

  final FlutterSecureStorage _storage;
  late final SecureCollectionStore<MedicalWatchArticle> _store;

  @override
  Future<List<MedicalWatchArticle>> getArticles({
    MedicalWatchSpecialty? specialty,
    int? limit,
  }) async {
    final articles = await _store.readAll();

    var filtered = articles;
    if (specialty != null) {
      filtered = filtered.where((a) => a.specialty == specialty).toList();
    }

    if (limit != null && filtered.length > limit) {
      filtered = filtered.sublist(0, limit);
    }

    return filtered;
  }

  @override
  Future<List<MedicalWatchArticle>> searchPubmed(
    String query, {
    int maxResults = 10,
  }) async {
    // La recherche PubMed n'est pas disponible hors-ligne.
    // On filtre les articles locaux par titre / abstract à la place.
    final articles = await _store.readAll();
    final q = query.toLowerCase();

    return articles
        .where((a) =>
            a.title.toLowerCase().contains(q) ||
            a.abstract_.toLowerCase().contains(q))
        .take(maxResults)
        .toList();
  }

  @override
  Future<void> triggerSync() async {
    // Pas de synchronisation possible hors-ligne.
  }

  /// Persiste une liste d'articles en stockage local chiffré.
  /// Utilisé par le [DynamicMedicalWatchRepository] pour mettre en cache
  /// les résultats obtenus depuis l'API.
  Future<void> cacheArticles(List<MedicalWatchArticle> articles) =>
      _store.replaceAll(articles);
}
