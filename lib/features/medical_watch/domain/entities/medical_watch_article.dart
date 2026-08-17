import 'package:equatable/equatable.dart';

import 'package:medicail/features/medical_watch/domain/enums/medical_watch_specialty.dart';

/// Entité métier représentant un article de veille médicale issu de PubMed.
class MedicalWatchArticle extends Equatable {
  const MedicalWatchArticle({
    required this.pmid,
    required this.title,
    required this.abstract_,
    required this.authors,
    this.specialty,
    this.publicationDate,
    this.doi,
    this.searchQuery,
    this.fetchedAt,
  });

  /// Identifiant PubMed unique de l'article.
  final String pmid;

  /// Titre complet de l'article.
  final String title;

  /// Résumé (abstract) de l'article.
  /// Nommé `abstract_` pour éviter le conflit avec le mot-clé Dart `abstract`.
  final String abstract_;

  /// Liste des noms d'auteurs.
  final List<String> authors;

  /// Spécialité associée (présente uniquement pour les articles de veille,
  /// pas pour les résultats de recherche PubMed directe).
  final MedicalWatchSpecialty? specialty;

  /// Année ou date de publication (chaîne libre fournie par l'API NCBI).
  final String? publicationDate;

  /// Digital Object Identifier de l'article.
  final String? doi;

  /// Requête de recherche ayant ramené cet article (veille automatique).
  final String? searchQuery;

  /// Date à laquelle l'article a été récupéré par le cron backend.
  final DateTime? fetchedAt;

  /// URL publique vers l'article sur le site PubMed.
  String get pubmedUrl => 'https://pubmed.ncbi.nlm.nih.gov/$pmid/';

  @override
  List<Object?> get props => [
        pmid,
        title,
        abstract_,
        authors,
        specialty,
        publicationDate,
        doi,
        searchQuery,
        fetchedAt,
      ];
}
