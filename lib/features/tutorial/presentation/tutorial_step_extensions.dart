import 'package:medicail/features/tutorial/domain/tutorial_flow.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_bloc.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_event.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_state.dart';

extension TutorialStateStepX on TutorialState {
  TutorialStepId? get tutorialStepId {
    final state = this;
    if (state is! TutorialInProgress) return null;
    return TutorialFlow.idFromIndex(state.currentStep);
  }

  bool isTutorialStep(TutorialStepId id) {
    return tutorialStepId == id;
  }

  bool isAnyTutorialStep(Iterable<TutorialStepId> ids) {
    final currentStepId = tutorialStepId;
    return currentStepId != null && ids.contains(currentStepId);
  }
}

extension TutorialBlocStepX on TutorialBloc {
  bool isCurrentStep(TutorialStepId id) {
    return state.isTutorialStep(id);
  }

  void completeStep(TutorialStepId id) {
    if (!isCurrentStep(id)) return;
    add(TutorialStepCompleted(TutorialFlow.indexOf(id)));
  }
}
