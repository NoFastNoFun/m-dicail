abstract class TutorialRepository {
  Future<bool> hasCompletedTutorial();
  Future<void> setTutorialCompleted();
  Future<void> resetTutorial();
}
