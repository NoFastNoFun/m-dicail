import 'package:flutter/material.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/screenshot/screen_protection.dart';

/// Blacks out the UI in the app switcher when a PHI route is active.
///
/// Complements native iOS resign-active covering and Android FLAG_SECURE.
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
    if (!_protection.isEnabled && _obscure && mounted) {
      setState(() => _obscure = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final shouldObscure = _protection.isEnabled &&
        (state == AppLifecycleState.inactive ||
            state == AppLifecycleState.paused ||
            state == AppLifecycleState.hidden);
    if (shouldObscure == _obscure) return;
    setState(() => _obscure = shouldObscure);
  }

  @override
  Widget build(BuildContext context) {
    if (!_obscure) return widget.child;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        const ColoredBox(color: Colors.black),
      ],
    );
  }
}
