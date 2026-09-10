import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medicail/core/config/app_platform.dart';

abstract final class AppSystemUi {
  static Future<void> configure() async {
    if (isDesktopPlatform) return;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  static SystemUiOverlayStyle overlayStyle(Brightness brightness) {
    final iconBrightness = brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      statusBarIconBrightness: iconBrightness,
      systemNavigationBarIconBrightness: iconBrightness,
    );
  }
}
