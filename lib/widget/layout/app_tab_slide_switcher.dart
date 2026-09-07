import 'package:flutter/material.dart';

class AppTabSlideSwitcher extends StatefulWidget {
  const AppTabSlideSwitcher({
    super.key,
    required this.tabIndex,
    required this.child,
  });

  final int tabIndex;
  final Widget child;

  static const Duration duration = Duration(milliseconds: 280);

  @override
  State<AppTabSlideSwitcher> createState() => _AppTabSlideSwitcherState();
}

class _AppTabSlideSwitcherState extends State<AppTabSlideSwitcher>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _direction = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTabSlideSwitcher.duration,
      value: 1,
    );
  }

  @override
  void didUpdateWidget(AppTabSlideSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabIndex == oldWidget.tabIndex) return;

    _direction = widget.tabIndex >= oldWidget.tabIndex ? 1 : -1;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(_direction, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: SizedBox.expand(child: widget.child),
      ),
    );
  }
}
