import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/features/tutorial/domain/repositories/tutorial_repository.dart';

@LazySingleton(as: TutorialRepository)
class TutorialRepositoryImpl implements TutorialRepository {
  TutorialRepositoryImpl(this._storage);

  final FlutterSecureStorage _storage;
  static const _key = 'tutorial_completed';

  @override
  Future<bool> hasCompletedTutorial() async {
    final value = await _storage.read(key: _key);
    return value == 'true';
  }

  @override
  Future<void> setTutorialCompleted() async {
    await _storage.write(key: _key, value: 'true');
  }

  @override
  Future<void> resetTutorial() async {
    await _storage.delete(key: _key);
  }
}
