import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/error/failure.dart';
import 'package:medicail/features/medical_watch/domain/entities/medical_watch_article.dart';
import 'package:medicail/features/medical_watch/domain/entities/medical_watch_specialty.dart';
import 'package:medicail/features/medical_watch/domain/repositories/medical_watch_repository.dart';
import 'package:medicail/features/medical_watch/presentation/medical_watch_event.dart';
import 'package:medicail/features/medical_watch/presentation/medical_watch_state.dart';

@injectable
class MedicalWatchBloc extends Bloc<MedicalWatchEvent, MedicalWatchState> {
  MedicalWatchBloc(this._repository) : super(const MedicalWatchInitial()) {
    on<MedicalWatchRequested>(_onRequested);
    on<MedicalWatchSpecialtyChanged>(_onSpecialtyChanged);
    on<MedicalWatchRefreshRequested>(_onRefreshRequested);
  }

  final MedicalWatchRepository _repository;

  Future<void> _onRequested(
    MedicalWatchRequested event,
    Emitter<MedicalWatchState> emit,
  ) async {
    await _loadArticles(
      emit,
      specialty: event.specialty,
      limit: event.limit,
    );
  }

  Future<void> _onSpecialtyChanged(
    MedicalWatchSpecialtyChanged event,
    Emitter<MedicalWatchState> emit,
  ) async {
    await _loadArticles(
      emit,
      specialty: event.specialty,
    );
  }

  Future<void> _onRefreshRequested(
    MedicalWatchRefreshRequested event,
    Emitter<MedicalWatchState> emit,
  ) async {
    await _loadArticles(
      emit,
      specialty: state.selectedSpecialty,
      limit: event.limit,
    );
  }

  Future<void> _loadArticles(
    Emitter<MedicalWatchState> emit, {
    MedicalWatchSpecialty? specialty,
    int limit = 50,
  }) async {
    final previousArticles = _articlesFromState(state);
    emit(
      MedicalWatchLoading(
        selectedSpecialty: specialty,
        previousArticles: previousArticles,
      ),
    );

    try {
      final articles = await _repository.getArticles(
        specialty: specialty,
        limit: limit,
      );
      emit(
        MedicalWatchLoaded(
          selectedSpecialty: specialty,
          articles: articles,
        ),
      );
    } catch (error) {
      emit(
        MedicalWatchFailure(
          selectedSpecialty: specialty,
          message: Failure.fromException(error).message,
          articles: previousArticles,
        ),
      );
    }
  }

  List<MedicalWatchArticle> _articlesFromState(MedicalWatchState state) {
    return switch (state) {
      MedicalWatchLoaded(:final articles) => articles,
      MedicalWatchLoading(:final previousArticles) => previousArticles,
      MedicalWatchFailure(:final articles) => articles,
      MedicalWatchInitial() => const [],
    };
  }
}
