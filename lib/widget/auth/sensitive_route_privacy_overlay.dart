import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:medicail/core/config/app_platform.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/screenshot/screen_protection.dart';

/// Blacks out the UI in the app switcher when a PHI route is active.
///
/// Complements native iOS resign-active covering and Android FLAG_SECURE.
/// On desktop, [AppLifecycleState.inactive] fires on focus loss (Alt-Tab,
/// tiled windows) while the window may still be visible, so only
/// [AppLifecycleState.paused] / [AppLifecycleState.hidden] obscure there.
class SensitiveRoutePrivacyOverlay extends StatefulWidget {
  const SensitiveRoutePrivacyOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<SensitiveRoutePrivacyOverlay> createState() =>
      _SensitiveRoutePrivacyOverlayState();
}

class _SensitiveRoutePrivacyOverlayState
    extends State<SensitiveRoutePrivacyOverlay>
    with WidgetsBindingObserver {
  final _protection = getIt<ScreenProtectionController>();
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _protection.addListener(_onProtectionChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _protection.removeListener(_onProtectionChanged);
    super.dispose();
  }

  void _onProtectionChanged() {
    if (!_protection.isEnabled && _obscure) {
      _setObscure(false);
    }
  }

  void _setObscure(bool shouldObscure) {
    if (!mounted || shouldObscure == _obscure) return;
    void apply() {
      if (!mounted || shouldObscure == _obscure) return;
      setState(() => _obscure = shouldObscure);
    }

    if (context.owner?.debugBuilding ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) => apply());
      SchedulerBinding.instance.ensureVisualUpdate();
      return;
    }
    apply();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final shouldObscure = _protection.isEnabled &&
        (state == AppLifecycleState.paused ||
            state == AppLifecycleState.hidden ||
            (!isDesktopPlatform && state == AppLifecycleState.inactive));
    _setObscure(shouldObscure);
  }

  @override
  Widget build(BuildContext context) {
    // Keep [widget.child] (GoRouter's Navigator, GlobalKey) in a stable slot.
    // Returning the child unwrapped when not obscured remounts that GlobalKey.
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_obscure) const ColoredBox(color: Colors.black),
      ],
    );
  }
}
