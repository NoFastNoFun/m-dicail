import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/storage/secure_storage_safe.dart';

abstract class AppSessionStorage {
  Future<bool> hasCompletedOnboarding();

  Future<void> markOnboardingCompleted();

  Future<String?> readRememberedEmail();

  Future<void> writeRememberedEmail(String? email);

  Future<bool> readBiometricLockEnabled();

  Future<void> writeBiometricLockEnabled(bool enabled);
}

@LazySingleton(as: AppSessionStorage)
class SecureAppSessionStorage implements AppSessionStorage {
  SecureAppSessionStorage(this._storage);

  static const String _onboardingKey = 'onboarding_completed';
  static const String _rememberedEmailKey = 'remembered_email';
  static const String _biometricLockKey = 'biometric_lock_enabled';

  final FlutterSecureStorage _storage;

  @override
  Future<bool> hasCompletedOnboarding() async {
    final value = await SecureStorageSafe.read(_storage, key: _onboardingKey);
    return value == 'true';
  }

  @override
  Future<void> markOnboardingCompleted() async {
    await SecureStorageSafe.write(
      _storage,
      key: _onboardingKey,
      value: 'true',
    );
  }

  @override
  Future<String?> readRememberedEmail() async {
    final value = await SecureStorageSafe.read(
      _storage,
      key: _rememberedEmailKey,
    );
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value.trim();
  }

  @override
  Future<void> writeRememberedEmail(String? email) async {
    final trimmed = email?.trim() ?? '';
    await SecureStorageSafe.write(
      _storage,
      key: _rememberedEmailKey,
      value: trimmed.isEmpty ? null : trimmed,
    );
  }

  @override
  Future<bool> readBiometricLockEnabled() async {
    final value = await SecureStorageSafe.read(
      _storage,
      key: _biometricLockKey,
    );
    return value == 'true';
  }

  @override
  Future<void> writeBiometricLockEnabled(bool enabled) async {
    await SecureStorageSafe.write(
      _storage,
      key: _biometricLockKey,
      value: enabled ? 'true' : 'false',
    );
  }
}
