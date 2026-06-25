import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

abstract class AppSessionStorage {
  Future<bool> hasCompletedOnboarding();

  Future<void> markOnboardingCompleted();
}

@LazySingleton(as: AppSessionStorage)
class SecureAppSessionStorage implements AppSessionStorage {
  SecureAppSessionStorage(this._storage);

  static const String _onboardingKey = 'onboarding_completed';

  final FlutterSecureStorage _storage;

  @override
  Future<bool> hasCompletedOnboarding() async {
    final value = await _storage.read(key: _onboardingKey);
    return value == 'true';
  }

  @override
  Future<void> markOnboardingCompleted() async {
    await _storage.write(key: _onboardingKey, value: 'true');
  }
}
