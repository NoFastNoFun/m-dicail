import 'package:flutter/foundation.dart';

bool get isDesktopPlatform =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows);

/// Desktop debug-only backend URL override. Tree-shaken out of release builds.
bool get isDesktopDebugBackendUrlEnabled => kDebugMode && isDesktopPlatform;
