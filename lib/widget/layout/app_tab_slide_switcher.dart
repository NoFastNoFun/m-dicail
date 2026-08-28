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

class _AppTabSlideSwitcherState extends State<AppTabSlideSwitcher> {
  double _direction = 1;

  @override
  void didUpdateWidget(AppTabSlideSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabIndex != oldWidget.tabIndex) {
      _direction = widget.tabIndex >= oldWidget.tabIndex ? 1 : -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return ClipRect(
      child: AnimatedSwitcher(
        duration: reduceMotion ? Duration.zero : AppTabSlideSwitcher.duration,
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            fit: StackFit.expand,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        transitionBuilder: (child, animation) {
          final isIncoming = child.key == ValueKey(widget.tabIndex);
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: Offset(isIncoming ? _direction : -_direction, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey(widget.tabIndex),
          child: SizedBox.expand(child: widget.child),
        ),
      ),
    );
  }
}
