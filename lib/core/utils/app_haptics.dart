import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Optional native feedback; never delays or prevents the associated action.
abstract final class AppHaptics {
  static void tap() {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }
    unawaited(_lightImpact());
  }

  static Future<void> _lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } on MissingPluginException {
      // Some targets do not expose native haptics.
    } on PlatformException {
      // Feedback is optional; the button action must still succeed.
    }
  }
}
