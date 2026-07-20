import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/features/tutorial/domain/repositories/tutorial_repository.dart';

@LazySingleton(as: TutorialRepository)
class TutorialRepositoryImpl implements TutorialRepository {
  TutorialRepositoryImpl(this._storage);

  final FlutterSecureStorage _storage;
  static const _keyCompleted = 'tutorial_completed';
  static const _keyCurrentStep = 'tutorial_current_step';

  @override
  Future<bool> hasCompletedTutorial() async {
    final value = await _storage.read(key: _keyCompleted);
    return value == 'true';
  }

  @override
  Future<void> setTutorialCompleted() async {
    await _storage.write(key: _keyCompleted, value: 'true');
    await clearCurrentTutorialStep();
  }

  @override
  Future<void> resetTutorial() async {
    await _storage.delete(key: _keyCompleted);
    await clearCurrentTutorialStep();
  }

  @override
  Future<int?> getCurrentTutorialStep() async {
    final value = await _storage.read(key: _keyCurrentStep);
    if (value != null) {
      return int.tryParse(value);
    }
    return null;
  }

  @override
  Future<void> setCurrentTutorialStep(int step) async {
    await _storage.write(key: _keyCurrentStep, value: step.toString());
  }

  @override
  Future<void> clearCurrentTutorialStep() async {
    await _storage.delete(key: _keyCurrentStep);
  }
}
