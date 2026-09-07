import 'package:flutter/material.dart';

/// Slides [child] horizontally when [tabIndex] changes.
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
  double _direction = 1;
  late final AnimationController _controller;
  late final CurvedAnimation _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTabSlideSwitcher.duration,
      value: 1,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AppTabSlideSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabIndex != oldWidget.tabIndex) {
      _direction = widget.tabIndex >= oldWidget.tabIndex ? 1 : -1;
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.value = 1;
      } else {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return ClipRect(
      // ShellRoute owns a single Navigator with a GlobalKey. Keeping an outgoing
      // copy in AnimatedSwitcher mounts that Navigator twice during tab changes.
      child: SlideTransition(
        position: reduceMotion
            ? const AlwaysStoppedAnimation(Offset.zero)
            : Tween<Offset>(
                begin: Offset(_direction, 0),
                end: Offset.zero,
              ).animate(_animation),
        child: SizedBox.expand(child: widget.child),
      ),
    );
  }
}
