import 'package:equatable/equatable.dart';

import 'package:medicail/features/medical_watch/domain/enums/medical_watch_specialty.dart';

sealed class MedicalWatchEvent extends Equatable {
  const MedicalWatchEvent();

  @override
  List<Object?> get props => [];
}

/// Demande le chargement des articles de veille depuis le backend / cache local.
final class MedicalWatchArticlesRequested extends MedicalWatchEvent {
  const MedicalWatchArticlesRequested({this.specialty});

  final MedicalWatchSpecialty? specialty;

  @override
  List<Object?> get props => [specialty];
}

/// Lance une recherche directe sur PubMed.
final class MedicalWatchSearchRequested extends MedicalWatchEvent {
  const MedicalWatchSearchRequested(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Demande un rafraîchissement (pull-to-refresh / trigger sync).
final class MedicalWatchRefreshRequested extends MedicalWatchEvent {
  const MedicalWatchRefreshRequested();
}

/// Change le filtre de spécialité actif.
final class MedicalWatchSpecialtyChanged extends MedicalWatchEvent {
  const MedicalWatchSpecialtyChanged(this.specialty);

  final MedicalWatchSpecialty? specialty;

  @override
  List<Object?> get props => [specialty];
}

/// Réinitialise la recherche PubMed et revient à la vue veille.
final class MedicalWatchSearchCleared extends MedicalWatchEvent {
  const MedicalWatchSearchCleared();
}
