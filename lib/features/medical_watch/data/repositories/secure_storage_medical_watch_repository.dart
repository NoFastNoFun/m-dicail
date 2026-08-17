import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/features/medical_watch/data/models/medical_watch_article_model.dart';
import 'package:medicail/features/medical_watch/domain/entities/medical_watch_article.dart';
import 'package:medicail/features/medical_watch/domain/enums/medical_watch_specialty.dart';
import 'package:medicail/features/medical_watch/domain/repositories/medical_watch_repository.dart';

@injectable
class SecureStorageMedicalWatchRepository implements MedicalWatchRepository {
  const SecureStorageMedicalWatchRepository(this._storage);

  static const String _articlesKey = 'medical_watch_articles_v1';

  final FlutterSecureStorage _storage;

  @override
  Future<List<MedicalWatchArticle>> getArticles({
    MedicalWatchSpecialty? specialty,
    int? limit,
  }) async {
    final articles = await _readArticles();

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
    final articles = await _readArticles();
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
  Future<void> cacheArticles(List<MedicalWatchArticle> articles) async {
    final encoded = jsonEncode(
      articles
          .map(MedicalWatchArticleModel.fromEntity)
          .map((a) => a.toJson())
          .toList(),
    );
    await _storage.write(key: _articlesKey, value: encoded);
  }

  Future<List<MedicalWatchArticle>> _readArticles() async {
    try {
      final raw = await _storage.read(key: _articlesKey);
      if (raw == null || raw.isEmpty) return const [];

      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      return decoded
          .whereType<Map>()
          .map((json) =>
              MedicalWatchArticleModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (_) {
      await _storage.delete(key: _articlesKey);
      return const [];
    }
  }
}
