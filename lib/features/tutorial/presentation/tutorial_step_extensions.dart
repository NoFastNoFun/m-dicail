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

  /// Skips quick-record record-page showcases already covered by demo consultation.
  Future<void> skipQuickRecordPageTutorialSteps() async {
    while (state.isAnyTutorialStep(
      TutorialFlow.quickRecordPageDuplicateSteps,
    )) {
      final stepId = state.tutorialStepId;
      if (stepId == null) return;
      completeStep(stepId);
      await stream.firstWhere(
        (nextState) => nextState.tutorialStepId != stepId,
      );
    }
  }

  /// Completes the home quick-record showcase and advances to assign-patient.
  Future<void> completeHomeQuickRecordTutorial() async {
    if (!isCurrentStep(TutorialStepId.homeQuickRecord)) return;
    completeStep(TutorialStepId.homeQuickRecord);
    await stream.firstWhere(
      (nextState) =>
          nextState.tutorialStepId == TutorialStepId.quickRecordStart,
    );
    await skipQuickRecordPageTutorialSteps();
  }

  /// Quick record is only allowed once the home FAB step is done.
  bool get canOpenQuickRecordDuringTutorial {
    if (state is! TutorialInProgress) return true;
    final stepId = state.tutorialStepId;
    if (stepId == null) return true;
    return TutorialFlow.indexOf(stepId) >
        TutorialFlow.indexOf(TutorialStepId.homeQuickRecord);
  }
}
