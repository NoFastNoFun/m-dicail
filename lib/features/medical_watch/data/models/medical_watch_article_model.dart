import 'package:medicail/features/medical_watch/domain/entities/medical_watch_article.dart';
import 'package:medicail/features/medical_watch/domain/enums/medical_watch_specialty.dart';

/// Modèle de données sérialisable pour [MedicalWatchArticle].
///
/// Gère le parsing JSON depuis les deux endpoints backend :
/// - `GET /v1/medical-watch` (articles de veille avec specialty, search_query, fetched_at)
/// - `POST /v1/pubmed/search` (résultats de recherche directe, sans specialty)
final class MedicalWatchArticleModel extends MedicalWatchArticle {
  const MedicalWatchArticleModel({
    required super.pmid,
    required super.title,
    required super.abstract_,
    required super.authors,
    super.specialty,
    super.publicationDate,
    super.doi,
    super.searchQuery,
    super.fetchedAt,
  });

  factory MedicalWatchArticleModel.fromEntity(MedicalWatchArticle article) {
    return MedicalWatchArticleModel(
      pmid: article.pmid,
      title: article.title,
      abstract_: article.abstract_,
      authors: article.authors,
      specialty: article.specialty,
      publicationDate: article.publicationDate,
      doi: article.doi,
      searchQuery: article.searchQuery,
      fetchedAt: article.fetchedAt,
    );
  }

  /// Parse un article depuis le JSON backend.
  ///
  /// Clés attendues (snake_case depuis NestJS) :
  /// ```json
  /// {
  ///   "pmid": "12345",
  ///   "title": "...",
  ///   "abstract": "...",
  ///   "authors": ["Author 1", "Author 2"],
  ///   "publication_date": "2024",
  ///   "doi": "10.1234/test",
  ///   "specialty": "rehabilitation",        // optionnel (veille uniquement)
  ///   "search_query": "physiotherapy ...",   // optionnel (veille uniquement)
  ///   "fetched_at": "2024-06-01T..."         // optionnel (veille uniquement)
  /// }
  /// ```
  factory MedicalWatchArticleModel.fromJson(Map<String, dynamic> json) {
    return MedicalWatchArticleModel(
      pmid: json['pmid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      abstract_: json['abstract'] as String? ?? '',
      authors: _parseAuthors(json['authors']),
      specialty: MedicalWatchSpecialty.fromValue(json['specialty'] as String?),
      publicationDate: json['publication_date'] as String?,
      doi: json['doi'] as String?,
      searchQuery: json['search_query'] as String?,
      fetchedAt: _parseNullableDate(json['fetched_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pmid': pmid,
      'title': title,
      'abstract': abstract_,
      'authors': authors,
      'publication_date': publicationDate,
      'doi': doi,
      if (specialty != null) 'specialty': specialty!.value,
      if (searchQuery != null) 'search_query': searchQuery,
      if (fetchedAt != null) 'fetched_at': fetchedAt!.toIso8601String(),
    };
  }

  static List<String> _parseAuthors(Object? value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return const [];
  }

  static DateTime? _parseNullableDate(Object? value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
