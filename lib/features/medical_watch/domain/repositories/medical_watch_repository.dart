import 'package:medicail/features/medical_watch/domain/entities/medical_watch_article.dart';
import 'package:medicail/features/medical_watch/domain/enums/medical_watch_specialty.dart';

/// Contrat abstrait pour l'accès aux articles de veille médicale.
abstract class MedicalWatchRepository {
  /// Récupère les articles de veille médicale stockés en base.
  ///
  /// [specialty] filtre optionnel par spécialité.
  /// [limit] nombre maximum d'articles à retourner (défaut côté API : 50).
  Future<List<MedicalWatchArticle>> getArticles({
    MedicalWatchSpecialty? specialty,
    int? limit,
  });

  /// Lance une recherche directe sur PubMed via le backend.
  ///
  /// [query] termes de recherche.
  /// [maxResults] nombre maximum de résultats (défaut : 10).
  Future<List<MedicalWatchArticle>> searchPubmed(
    String query, {
    int maxResults,
  });

  /// Déclenche manuellement la synchronisation de la veille
  /// (équivalent au cron backend).
  Future<void> triggerSync();
}
