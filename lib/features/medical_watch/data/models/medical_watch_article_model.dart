import 'package:medicail/features/medical_watch/domain/entities/medical_watch_article.dart';
import 'package:medicail/features/medical_watch/domain/entities/medical_watch_specialty.dart';

final class MedicalWatchArticleModel extends MedicalWatchArticle {
  const MedicalWatchArticleModel({
    required super.pmid,
    required super.specialty,
    required super.title,
    required super.abstractText,
    required super.authors,
    required super.searchQuery,
    required super.fetchedAt,
    super.publicationDate,
    super.doi,
  });

  factory MedicalWatchArticleModel.fromEntity(MedicalWatchArticle article) {
    return MedicalWatchArticleModel(
      pmid: article.pmid,
      specialty: article.specialty,
      title: article.title,
      abstractText: article.abstractText,
      authors: article.authors,
      publicationDate: article.publicationDate,
      doi: article.doi,
      searchQuery: article.searchQuery,
      fetchedAt: article.fetchedAt,
    );
  }

  factory MedicalWatchArticleModel.fromJson(Map<String, dynamic> json) {
    return MedicalWatchArticleModel(
      pmid: json['pmid']?.toString() ?? '',
      specialty: medicalWatchSpecialtyFromApiValue(
        json['specialty']?.toString() ?? '',
      ),
      title: _parseNullableString(json['title']) ?? '',
      abstractText: _parseNullableString(json['abstract']) ??
          _parseNullableString(json['abstractText']) ??
          '',
      authors: _parseAuthors(json['authors']),
      publicationDate: _parseNullableString(json['publicationDate']) ??
          _parseNullableString(json['publication_date']),
      doi: _parseNullableString(json['doi']),
      searchQuery: _parseNullableString(json['searchQuery']) ??
          _parseNullableString(json['search_query']) ??
          '',
      fetchedAt: _parseDate(json['fetchedAt'] ?? json['fetched_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pmid': pmid,
      'specialty': specialty.apiValue,
      'title': title,
      'abstract': abstractText,
      'authors': authors,
      'publicationDate': publicationDate,
      'doi': doi,
      'searchQuery': searchQuery,
      'fetchedAt': fetchedAt.toIso8601String(),
    };
  }

  static List<String> _parseAuthors(Object? value) {
    if (value is! List) {
      return [];
    }
    return value.map((author) => author.toString()).toList();
  }

  static String? _parseNullableString(Object? value) {
    if (value == null) {
      return null;
    }
    return value.toString();
  }

  static DateTime _parseDate(Object? value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }
}
