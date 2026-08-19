import 'package:equatable/equatable.dart';

import 'package:medicail/features/medical_watch/domain/entities/medical_watch_article.dart';
import 'package:medicail/features/medical_watch/domain/enums/medical_watch_specialty.dart';

sealed class MedicalWatchState extends Equatable {
  const MedicalWatchState();

  @override
  List<Object?> get props => [];
}

final class MedicalWatchInitial extends MedicalWatchState {
  const MedicalWatchInitial();
}

final class MedicalWatchLoading extends MedicalWatchState {
  const MedicalWatchLoading();
}

final class MedicalWatchLoaded extends MedicalWatchState {
  const MedicalWatchLoaded({
    required this.articles,
    this.selectedSpecialty,
    this.isSearchMode = false,
    this.searchQuery,
  });

  final List<MedicalWatchArticle> articles;
  final MedicalWatchSpecialty? selectedSpecialty;
  final bool isSearchMode;
  final String? searchQuery;

  @override
  List<Object?> get props => [
        articles,
        selectedSpecialty,
        isSearchMode,
        searchQuery,
      ];
}

final class MedicalWatchFailure extends MedicalWatchState {
  const MedicalWatchFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
