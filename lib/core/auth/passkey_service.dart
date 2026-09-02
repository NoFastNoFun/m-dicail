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

  Future<Map<String, dynamic>> register(Map<String, dynamic> options) async {
    final request = RegisterRequestType.fromJsonString(jsonEncode(options));
    final response = await _authenticator.register(request);
    return response.toJson();
  }

  Future<Map<String, dynamic>> authenticate(Map<String, dynamic> options) async {
    final request = AuthenticateRequestType.fromJsonString(jsonEncode(options));
    final response = await _authenticator.authenticate(request);
    return response.toJson();
  }
}
