import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

abstract class AppSessionStorage {
  Future<bool> hasCompletedOnboarding();

  Future<void> markOnboardingCompleted();

  Future<String?> readRememberedEmail();

  Future<void> writeRememberedEmail(String? email);
}

@LazySingleton(as: AppSessionStorage)
class SecureAppSessionStorage implements AppSessionStorage {
  SecureAppSessionStorage(this._storage);

  static const String _onboardingKey = 'onboarding_completed';
  static const String _rememberedEmailKey = 'remembered_email';

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

  @override
  Future<String?> readRememberedEmail() async {
    final value = await _storage.read(key: _rememberedEmailKey);
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value.trim();
  }

  @override
  Future<void> writeRememberedEmail(String? email) async {
    final trimmed = email?.trim() ?? '';
    if (trimmed.isEmpty) {
      await _storage.delete(key: _rememberedEmailKey);
      return;
    }
    await _storage.write(key: _rememberedEmailKey, value: trimmed);
  }
}
