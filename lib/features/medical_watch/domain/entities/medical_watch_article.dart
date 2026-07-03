import 'package:equatable/equatable.dart';
import 'package:medicail/features/medical_watch/domain/entities/medical_watch_specialty.dart';

class MedicalWatchArticle extends Equatable {
  const MedicalWatchArticle({
    required this.pmid,
    required this.specialty,
    required this.title,
    required this.abstractText,
    required this.authors,
    required this.searchQuery,
    required this.fetchedAt,
    this.publicationDate,
    this.doi,
  });

  final String pmid;
  final MedicalWatchSpecialty specialty;
  final String title;
  final String abstractText;
  final List<String> authors;
  final String? publicationDate;
  final String? doi;
  final String searchQuery;
  final DateTime fetchedAt;

  MedicalWatchArticle copyWith({
    String? pmid,
    MedicalWatchSpecialty? specialty,
    String? title,
    String? abstractText,
    List<String>? authors,
    String? publicationDate,
    String? doi,
    String? searchQuery,
    DateTime? fetchedAt,
    bool clearPublicationDate = false,
    bool clearDoi = false,
  }) {
    return MedicalWatchArticle(
      pmid: pmid ?? this.pmid,
      specialty: specialty ?? this.specialty,
      title: title ?? this.title,
      abstractText: abstractText ?? this.abstractText,
      authors: authors ?? this.authors,
      publicationDate:
          clearPublicationDate ? null : publicationDate ?? this.publicationDate,
      doi: clearDoi ? null : doi ?? this.doi,
      searchQuery: searchQuery ?? this.searchQuery,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  List<Object?> get props => [
        pmid,
        specialty,
        title,
        abstractText,
        authors,
        publicationDate,
        doi,
        searchQuery,
        fetchedAt,
      ];
}
