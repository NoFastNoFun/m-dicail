import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';

@lazySingleton
class BiometricAuthService {
  BiometricAuthService() : _localAuthentication = LocalAuthentication();

  final LocalAuthentication _localAuthentication;

  Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    try {
      if (!(Platform.isAndroid ||
          Platform.isIOS ||
          Platform.isWindows ||
          Platform.isMacOS)) {
        return false;
      }
      final canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
      final isDeviceSupported = await _localAuthentication.isDeviceSupported();
      return canCheckBiometrics || isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate({required String reason}) async {
    if (!await isAvailable()) return false;
    try {
      return await _localAuthentication.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
