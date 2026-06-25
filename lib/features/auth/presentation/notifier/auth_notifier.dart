import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AuthNotifier extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isGuest = false;
  bool _hasCompletedOnboarding = false;

  bool get isAuthenticated => _isAuthenticated;

  bool get isGuest => _isGuest;

  bool get canAccessApp => _isAuthenticated || _isGuest;

  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  void setAuthenticated(bool value) {
    if (_isAuthenticated != value) {
      _isAuthenticated = value;
      if (value) {
        _isGuest = false;
      }
      notifyListeners();
    }
  }

  void setGuest(bool value) {
    if (_isGuest != value) {
      _isGuest = value;
      if (value) {
        _isAuthenticated = false;
      }
      notifyListeners();
    }
  }

  void setHasCompletedOnboarding(bool value) {
    if (_hasCompletedOnboarding != value) {
      _hasCompletedOnboarding = value;
      notifyListeners();
    }
  }
}
