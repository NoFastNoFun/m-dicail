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

  bool _isHydrated = false;
  bool _isLockEnabled = false;
  bool _isLocked = true;
  bool _isAuthenticating = false;

  bool get isHydrated => _isHydrated;

  bool get isEnabled => _isLockEnabled;

  bool get isLocked => _isLocked;

  bool get isAuthenticating => _isAuthenticating;

  bool get shouldShowLock {
    if (!_isHydrated || !_isLockEnabled) return false;
    if (!_authNotifier.canAccessApp) return false;
    return _isLocked;
  }

  Future<void> hydrate() async {
    try {
      _isLockEnabled = await _sessionStorage.readBiometricLockEnabled();
    } catch (_) {
      _isLockEnabled = false;
    }
    _isLocked = _isLockEnabled;
    _isHydrated = true;
    notifyListeners();
  }

  Future<bool> setEnabled(bool enabled, {required String reason}) async {
    final didAuthenticate = await _biometricAuth.authenticate(reason: reason);
    if (!didAuthenticate) return false;
    await _sessionStorage.writeBiometricLockEnabled(enabled);
    _isLockEnabled = enabled;
    _isLocked = false;
    notifyListeners();
    return true;
  }

  void lockIfNeeded() {
    if (!_isHydrated || !_isLockEnabled || !_authNotifier.canAccessApp) return;
    if (_isLocked) return;
    _isLocked = true;
    notifyListeners();
  }

  void unlockWithoutAuth() {
    if (!_isLocked) return;
    _isLocked = false;
    notifyListeners();
  }

  Future<bool> unlock({required String reason}) async {
    if (!_isLocked) return true;
    if (_isAuthenticating) return false;
    _isAuthenticating = true;
    notifyListeners();
    try {
      final didAuthenticate = await _biometricAuth.authenticate(reason: reason);
      if (didAuthenticate) {
        _isLocked = false;
      }
      return didAuthenticate;
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  void onAuthAccessChanged() {
    if (!_authNotifier.canAccessApp && _isLocked) {
      _isLocked = false;
      notifyListeners();
    }
  }
}
