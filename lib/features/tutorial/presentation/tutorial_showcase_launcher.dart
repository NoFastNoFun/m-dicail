import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class TutorialShowcaseLauncher {
  TutorialShowcaseLauncher._();

  static Future<bool> startWhenReady({
    required BuildContext context,
    required GlobalKey key,
    int maxAttempts = 5,
    Duration delay = const Duration(milliseconds: 150),
  }) async {
    for (int i = 0; i < maxAttempts; i++) {
      await Future.delayed(delay);
      if (!context.mounted) return false;
      final overlay = Overlay.maybeOf(context);
      if (overlay != null) {
        try {
          ShowcaseView.get().startShowCase(
            [key],
            delay: const Duration(milliseconds: 350),
          );
        } catch (e) {
          // Ignore silently
        }
        return true;
      }
    }
    return false;
  }
}
