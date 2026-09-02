import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:medicail/features/tutorial/domain/repositories/tutorial_repository.dart';
import 'package:medicail/features/tutorial/domain/tutorial_flow.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_event.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_state.dart';

@injectable
class TutorialBloc extends Bloc<TutorialEvent, TutorialState> {
  TutorialBloc(
    this._repository,
    this._recordingSessionRepository,
  ) : super(const TutorialLoading()) {
    on<TutorialCheckRequested>(_onCheckRequested);
    on<TutorialStartRequested>(_onStartRequested);
    on<TutorialStepCompleted>(_onStepCompleted);
    on<TutorialSkipRequested>(_onSkipRequested);
    on<TutorialResetRequested>(_onResetRequested);
  }

  final TutorialRepository _repository;
  final RecordingSessionRepository _recordingSessionRepository;

  Future<void> _purgeTutorialRecordings() {
    return _recordingSessionRepository.purgeTutorialSessions();
  }

  Future<void> _onCheckRequested(
    TutorialCheckRequested event,
    Emitter<TutorialState> emit,
  ) async {
    final completed = await _repository.hasCompletedTutorial();
    if (completed) {
      emit(const TutorialCompleted());
    } else {
      final currentStep = await _repository.getCurrentTutorialStep();
      if (currentStep != null) {
        emit(TutorialInProgress(currentStep));
      } else {
        emit(const TutorialInitial());
      }
    }
  }

  Future<void> _onStartRequested(
    TutorialStartRequested event,
    Emitter<TutorialState> emit,
  ) async {
    await _purgeTutorialRecordings();
    await _repository.resetTutorial();
    final firstStep = TutorialFlow.firstStep;
    await _repository.setCurrentTutorialStep(firstStep);
    emit(TutorialInProgress(firstStep));
  }

  Future<void> _onStepCompleted(
    TutorialStepCompleted event,
    Emitter<TutorialState> emit,
  ) async {
    final nextStep = TutorialFlow.nextStepAfter(event.completedStep);
    if (nextStep != null) {
      await _repository.setCurrentTutorialStep(nextStep);
      emit(TutorialInProgress(nextStep));
    } else {
      await _purgeTutorialRecordings();
      await _repository.setTutorialCompleted();
      emit(const TutorialCompleted());
    }
  }

  Future<void> _onSkipRequested(
    TutorialSkipRequested event,
    Emitter<TutorialState> emit,
  ) async {
    await _purgeTutorialRecordings();
    await _repository.setTutorialCompleted();
    emit(const TutorialCompleted());
  }

  Future<void> _onResetRequested(
    TutorialResetRequested event,
    Emitter<TutorialState> emit,
  ) async {
    await _purgeTutorialRecordings();
    await _repository.resetTutorial();
    emit(const TutorialInitial());
  }
}
