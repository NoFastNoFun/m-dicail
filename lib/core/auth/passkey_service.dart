import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';

@lazySingleton
class PasskeyService {
  PasskeyService() : _authenticator = PasskeyAuthenticator();

  final PasskeyAuthenticator _authenticator;

  Future<bool> isSupported() async {
    if (kIsWeb) {
      final availability = await _authenticator.getAvailability().web();
      return availability.hasPasskeySupport;
    }
    if (Platform.isAndroid) {
      final availability = await _authenticator.getAvailability().android();
      return availability.hasPasskeySupport;
    }
    if (Platform.isIOS) {
      final availability = await _authenticator.getAvailability().iOS();
      return availability.hasPasskeySupport;
    }
    if (Platform.isWindows) {
      final availability = await _authenticator.getAvailability().windows();
      return availability.hasPasskeySupport;
    }
    return false;
  }

  /// Whether the platform can offer passkeys via Conditional UI / autofill
  /// (WebAuthn `mediation: conditional`) without a dedicated modal prompt.
  ///
  /// - Web: uses `PublicKeyCredential.isConditionalMediationAvailable()`.
  /// - iOS: Darwin plugin supports `conditionalUI` (AutoFill).
  /// - Android: the current `passkeys_android` bridge does not plumb
  ///   `MediationType.Conditional`, so conditional autofill is unavailable —
  ///   callers should show a discreet modal fallback instead.
  /// - Other platforms: treat as unavailable.
  Future<bool> isConditionalMediationAvailable() async {
    if (kIsWeb) {
      final availability = await _authenticator.getAvailability().web();
      return availability.isConditionalMediationAvailable == true;
    }
    if (Platform.isIOS) {
      final availability = await _authenticator.getAvailability().iOS();
      return availability.hasPasskeySupport;
    }
    return false;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> options) async {
    final request = RegisterRequestType.fromJsonString(jsonEncode(options));
    final response = await _authenticator.register(request);
    return response.toJson();
  }

  /// Runs a WebAuthn assertion.
  ///
  /// When [conditional] is true, uses `mediation: conditional` and
  /// `preferImmediatelyAvailableCredentials: false` so the OS/password
  /// manager can surface passkeys in autofill instead of a blocking modal.
  Future<Map<String, dynamic>> authenticate(
    Map<String, dynamic> options, {
    bool conditional = false,
  }) async {
    final request = AuthenticateRequestType.fromJsonString(
      jsonEncode(options),
      mediation: conditional
          ? MediationType.Conditional
          : MediationType.Optional,
      preferImmediatelyAvailableCredentials: !conditional,
    );
    final response = await _authenticator.authenticate(request);
    return response.toJson();
  }

  Future<void> cancelCurrentOperation() {
    return _authenticator.cancelCurrentAuthenticatorOperation();
  }
}
