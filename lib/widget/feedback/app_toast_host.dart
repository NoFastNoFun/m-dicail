import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/widget/feedback/app_toast.dart';

class AppToastHost extends StatefulWidget {
  const AppToastHost({
    super.key,
    required this.child,
  });

  final Widget child;

  static AppToastHostState? of(BuildContext context) {
    return context.findAncestorStateOfType<AppToastHostState>();
  }

  @override
  State<AppToastHost> createState() => AppToastHostState();
}

class AppToastHostState extends State<AppToastHost> {
  OverlayEntry? _entry;
  Timer? _timer;

  void show({
    required BuildContext overlayContext,
    required String message,
    required AppToastType type,
    required Duration duration,
  }) {
    _dismiss();

    final overlay = Overlay.of(overlayContext);

    _entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.paddingOf(context).top + AppSpacing.lg,
        left: 0,
        right: 0,
        child: AppToastWidget(
          message: message,
          type: type,
          onDismiss: _dismiss,
        ),
      ),
    );

    overlay.insert(_entry!);

    _timer = Timer(duration, _dismiss);
  }

  void _dismiss() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
