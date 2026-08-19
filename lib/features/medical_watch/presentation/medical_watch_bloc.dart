import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import 'package:medicail/core/error/failure.dart';
import 'package:medicail/features/medical_watch/domain/enums/medical_watch_specialty.dart';
import 'package:medicail/features/medical_watch/domain/repositories/medical_watch_repository.dart';
import 'package:medicail/features/medical_watch/presentation/medical_watch_event.dart';
import 'package:medicail/features/medical_watch/presentation/medical_watch_state.dart';

@injectable
class MedicalWatchBloc extends Bloc<MedicalWatchEvent, MedicalWatchState> {
  MedicalWatchBloc(this._repository) : super(const MedicalWatchInitial()) {
    on<MedicalWatchArticlesRequested>(_onArticlesRequested);
    on<MedicalWatchSearchRequested>(
      _onSearchRequested,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 500))
          .switchMap(mapper),
    );
    on<MedicalWatchRefreshRequested>(_onRefreshRequested);
    on<MedicalWatchSpecialtyChanged>(_onSpecialtyChanged);
    on<MedicalWatchSearchCleared>(_onSearchCleared);
  }

  final MedicalWatchRepository _repository;

  Future<void> _onArticlesRequested(
    MedicalWatchArticlesRequested event,
    Emitter<MedicalWatchState> emit,
  ) async {
    emit(const MedicalWatchLoading());
    await _loadArticles(emit, specialty: event.specialty);
  }

  Future<void> _onSearchRequested(
    MedicalWatchSearchRequested event,
    Emitter<MedicalWatchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      await _loadArticles(emit);
      return;
    }

    emit(const MedicalWatchLoading());
    try {
      final articles = await _repository.searchPubmed(query);
      emit(MedicalWatchLoaded(
        articles: articles,
        isSearchMode: true,
        searchQuery: query,
      ));
    } catch (error) {
      emit(MedicalWatchFailure(Failure.fromException(error).message));
    }
  }

  Future<void> _onRefreshRequested(
    MedicalWatchRefreshRequested event,
    Emitter<MedicalWatchState> emit,
  ) async {
    try {
      await _repository.triggerSync();
    } catch (_) {
      // La synchro est best-effort, on recharge quand même.
    }

    final currentSpecialty =
        state is MedicalWatchLoaded
            ? (state as MedicalWatchLoaded).selectedSpecialty
            : null;
    await _loadArticles(emit, specialty: currentSpecialty);
  }

  Future<void> _onSpecialtyChanged(
    MedicalWatchSpecialtyChanged event,
    Emitter<MedicalWatchState> emit,
  ) async {
    emit(const MedicalWatchLoading());
    await _loadArticles(emit, specialty: event.specialty);
  }

  Future<void> _onSearchCleared(
    MedicalWatchSearchCleared event,
    Emitter<MedicalWatchState> emit,
  ) async {
    emit(const MedicalWatchLoading());
    await _loadArticles(emit);
  }

  Future<void> _loadArticles(
    Emitter<MedicalWatchState> emit, {
    MedicalWatchSpecialty? specialty,
  }) async {
    try {
      final articles = await _repository.getArticles(specialty: specialty);
      emit(MedicalWatchLoaded(
        articles: articles,
        selectedSpecialty: specialty,
      ));
    } catch (error) {
      emit(MedicalWatchFailure(Failure.fromException(error).message));
    }
  }
}
