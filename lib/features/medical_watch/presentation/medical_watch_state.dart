import 'package:equatable/equatable.dart';
import 'package:medicail/features/medical_watch/domain/entities/medical_watch_article.dart';
import 'package:medicail/features/medical_watch/domain/entities/medical_watch_specialty.dart';

sealed class MedicalWatchState extends Equatable {
  const MedicalWatchState({this.selectedSpecialty});

  final MedicalWatchSpecialty? selectedSpecialty;

  @override
  List<Object?> get props => [selectedSpecialty];
}

final class MedicalWatchInitial extends MedicalWatchState {
  const MedicalWatchInitial({super.selectedSpecialty});
}

final class MedicalWatchLoading extends MedicalWatchState {
  const MedicalWatchLoading({
    super.selectedSpecialty,
    this.previousArticles = const [],
  });

  final List<MedicalWatchArticle> previousArticles;

  @override
  List<Object?> get props => [selectedSpecialty, previousArticles];
}

final class MedicalWatchLoaded extends MedicalWatchState {
  const MedicalWatchLoaded({
    required this.articles,
    super.selectedSpecialty,
  });

  final List<MedicalWatchArticle> articles;

  @override
  List<Object?> get props => [selectedSpecialty, articles];
}

final class MedicalWatchFailure extends MedicalWatchState {
  const MedicalWatchFailure({
    required this.message,
    super.selectedSpecialty,
    this.articles = const [],
  });

  final String message;
  final List<MedicalWatchArticle> articles;

  @override
  List<Object?> get props => [selectedSpecialty, message, articles];
}
