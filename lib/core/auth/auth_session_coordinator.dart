import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:medicail/core/network/auth_token_storage.dart';
import 'package:medicail/features/auth/presentation/notifier/auth_notifier.dart';

@lazySingleton
class AuthSessionCoordinator {
  AuthSessionCoordinator(this._tokenStorage, this._authNotifier);

  final AuthTokenStorage _tokenStorage;
  final AuthNotifier _authNotifier;
  final _sessionExpiredController = StreamController<void>.broadcast();

  Stream<void> get onSessionExpired => _sessionExpiredController.stream;

  Future<void> expireSession() async {
    await _tokenStorage.clearToken();
    _authNotifier.setAuthenticated(false);
    _authNotifier.setGuest(false);
    _sessionExpiredController.add(null);
  }

  @disposeMethod
  void dispose() {
    _sessionExpiredController.close();
  }
}
