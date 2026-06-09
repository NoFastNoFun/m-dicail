import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/features/tutorial/domain/repositories/tutorial_repository.dart';
import 'package:medicail/features/tutorial/domain/tutorial_flow.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_event.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_state.dart';

@injectable
class TutorialBloc extends Bloc<TutorialEvent, TutorialState> {
  TutorialBloc(this._repository) : super(const TutorialInitial()) {
    on<TutorialCheckRequested>(_onCheckRequested);
    on<TutorialStartRequested>(_onStartRequested);
    on<TutorialStepCompleted>(_onStepCompleted);
    on<TutorialSkipRequested>(_onSkipRequested);
  }

  final TutorialRepository _repository;

  Future<void> _onCheckRequested(
    TutorialCheckRequested event,
    Emitter<TutorialState> emit,
  ) async {
    final hasCompleted = await _repository.hasCompletedTutorial();
    if (hasCompleted) {
      emit(const TutorialCompleted());
    } else {
      // On the first check, we can automatically start at step 1 if not completed.
      // Wait, let's keep it Initial so the UI decides when to start.
      emit(const TutorialInitial());
    }
  }

  void _onStartRequested(
    TutorialStartRequested event,
    Emitter<TutorialState> emit,
  ) {
    if (state is! TutorialCompleted) {
      emit(TutorialInProgress(TutorialFlow.firstStep));
    }
  }

  Future<void> _onStepCompleted(
    TutorialStepCompleted event,
    Emitter<TutorialState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TutorialInProgress) return;
    if (event.completedStep != currentState.currentStep) return;

    final nextStep = TutorialFlow.nextStepAfter(currentState.currentStep);
    if (nextStep == null) {
      await _repository.setTutorialCompleted();
      emit(const TutorialCompleted());
    } else {
      emit(TutorialInProgress(nextStep));
    }
  }

  Future<void> _onSkipRequested(
    TutorialSkipRequested event,
    Emitter<TutorialState> emit,
  ) async {
    await _repository.setTutorialCompleted();
    emit(const TutorialCompleted());
  }
}
