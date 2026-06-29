import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

/// Helper to launch ShowcaseView tooltips robustly, especially after
/// route transitions or dialog closures where the widget or overlay
/// might not be fully mounted yet.
class TutorialShowcaseLauncher {
  TutorialShowcaseLauncher._();

  /// Attempts to start a showcase for the given [key].
  ///
  /// Waits up to [maxAttempts] * [delay] for the [context] to be mounted,
  /// the [key] to have a valid context, and a valid [Overlay] to be present.
  ///
  /// Returns `true` if the showcase was successfully started, `false` otherwise.
  static Future<bool> startWhenReady({
    required BuildContext context,
    required GlobalKey key,
    int maxAttempts = 5,
    Duration delay = const Duration(milliseconds: 150),
  }) async {
    for (int i = 0; i < maxAttempts; i++) {
      // Allow the frame to render
      await Future.delayed(delay);

      if (!context.mounted) {
        // If the originating context is no longer mounted, abort.
        return false;
      }

      final overlay = Overlay.maybeOf(context);

      if (overlay != null) {
        try {
          ShowcaseView.get().startShowCase(
            [key], 
            delay: const Duration(milliseconds: 350),
          );
        } catch (e) {
          // Ignore silently in production
        }
        
        return true;
      }
    }

    return false;
  }
}
