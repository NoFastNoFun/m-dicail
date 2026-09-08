import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/router/app_routes.dart';

/// Enables OS-level capture protection on PHI routes.
@lazySingleton
class ScreenProtectionController extends ChangeNotifier {
  ScreenProtectionController(this._router);

  static const MethodChannel _channel = MethodChannel(
    'dev.nf2.medicail/screen_protection',
  );

  final GoRouter _router;

  bool _enabled = false;
  bool _started = false;
  VoidCallback? _routerListener;

  bool get isEnabled => _enabled;

  bool get isSensitiveRoute => isSensitiveLocation(_router.state.uri.path);

  static bool isSensitiveLocation(String location) {
    if (location == AppRoutes.patients) return true;
    if (location == AppRoutes.record) return true;
    if (location.startsWith('${AppRoutes.patients}/')) return true;
    return false;
  }

  void start() {
    if (_started) return;
    _started = true;
    _routerListener = () => syncFromRoute();
    _router.routerDelegate.addListener(_routerListener!);
    syncFromRoute();
  }

  void disposeController() {
    if (_routerListener != null) {
      _router.routerDelegate.removeListener(_routerListener!);
      _routerListener = null;
    }
    _started = false;
  }

  Future<void> syncFromRoute() async {
    final shouldProtect = isSensitiveRoute;
    if (shouldProtect == _enabled) return;
    await setEnabled(shouldProtect);
  }

  Future<void> setEnabled(bool enabled) async {
    if (kIsWeb) {
      _enabled = false;
      notifyListeners();
      return;
    }
    try {
      await _channel.invokeMethod<void>('setEnabled', {'enabled': enabled});
      _enabled = enabled;
      notifyListeners();
    } catch (_) {
      // Best-effort; unsupported platforms stay unprotected.
      _enabled = false;
      notifyListeners();
    }
  }
}
