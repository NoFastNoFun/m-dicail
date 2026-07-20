abstract class TutorialRepository {
  Future<bool> hasCompletedTutorial();
  Future<void> setTutorialCompleted();
  Future<void> resetTutorial();

  Future<int?> getCurrentTutorialStep();
  Future<void> setCurrentTutorialStep(int step);
  Future<void> clearCurrentTutorialStep();
}
