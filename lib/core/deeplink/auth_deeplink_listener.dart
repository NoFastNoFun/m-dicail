import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/deeplink/auth_deeplink_mapper.dart';

/// Listens for cold-start and warm-start app links and navigates with [GoRouter].
class AuthDeeplinkListener {
  AuthDeeplinkListener({
    required GoRouter router,
    AppLinks? appLinks,
  })  : _router = router,
        _appLinks = appLinks ?? AppLinks();

  final GoRouter _router;
  final AppLinks _appLinks;
  StreamSubscription<Uri>? _subscription;
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    // uriLinkStream includes the cold-start link and further warm-start links.
    _subscription = _appLinks.uriLinkStream.listen(
      _navigate,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('AuthDeeplinkListener stream error: $error\n$stackTrace');
      },
    );
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _started = false;
  }

  void _navigate(Uri? uri) {
    if (uri == null) return;
    final location = mapIncomingAuthUri(uri);
    if (location == null) return;
    _router.go(location);
  }
}
