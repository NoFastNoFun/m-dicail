import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Emits when the OS reports a screenshot (iOS, Android 14+).
class ScreenshotDetector {
  ScreenshotDetector._();

  static const EventChannel _channel =
      EventChannel('dev.nf2.medicail/screenshot_detection');

  static bool get isSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  /// Stream of screenshot events. Empty / no events on unsupported platforms.
  static Stream<void> get screenshots {
    if (!isSupported) {
      return const Stream<void>.empty();
    }
    return _channel.receiveBroadcastStream().map((_) {});
  }
}
