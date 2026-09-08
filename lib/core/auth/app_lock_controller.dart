import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/auth/biometric_auth_service.dart';
import 'package:medicail/core/storage/app_session_storage.dart';
import 'package:medicail/features/auth/presentation/notifier/auth_notifier.dart';

@lazySingleton
class AppLockController extends ChangeNotifier {
  AppLockController(
    this._sessionStorage,
    this._biometricAuth,
    this._authNotifier,
  );

  final AppSessionStorage _sessionStorage;
  final BiometricAuthService _biometricAuth;
  final AuthNotifier _authNotifier;

  bool _hydrated = false;
  bool _enabled = false;
  bool _locked = true;
  bool _authenticating = false;

  bool get isHydrated => _hydrated;

  bool get isEnabled => _enabled;

  bool get isLocked => _locked;

  bool get isAuthenticating => _authenticating;

  bool get shouldShowLock {
    if (!_hydrated || !_enabled) return false;
    if (!_authNotifier.canAccessApp) return false;
    return _locked;
  }

  Future<void> hydrate() async {
    try {
      _enabled = await _sessionStorage.readBiometricLockEnabled();
    } catch (_) {
      _enabled = false;
    }
    _locked = _enabled;
    _hydrated = true;
    notifyListeners();
  }

  Future<bool> setEnabled(bool enabled, {required String reason}) async {
    final ok = await _biometricAuth.authenticate(reason: reason);
    if (!ok) return false;
    await _sessionStorage.writeBiometricLockEnabled(enabled);
    _enabled = enabled;
    _locked = false;
    notifyListeners();
    return true;
  }

  void lockIfNeeded() {
    if (!_hydrated || !_enabled || !_authNotifier.canAccessApp) return;
    if (_locked) return;
    _locked = true;
    notifyListeners();
  }

  void unlockWithoutAuth() {
    if (!_locked) return;
    _locked = false;
    notifyListeners();
  }

  Future<bool> unlock({required String reason}) async {
    if (!_locked) return true;
    if (_authenticating) return false;
    _authenticating = true;
    notifyListeners();
    try {
      final ok = await _biometricAuth.authenticate(reason: reason);
      if (ok) {
        _locked = false;
      }
      return ok;
    } finally {
      _authenticating = false;
      notifyListeners();
    }
  }

  void onAuthAccessChanged() {
    if (!_authNotifier.canAccessApp && _locked) {
      _locked = false;
      notifyListeners();
    }
  }
}
