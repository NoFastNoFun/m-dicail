import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';

enum AppRadialActionAnchor { center, end }

class AppRadialAction {
  const AppRadialAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class AppRadialActionButton extends StatefulWidget {
  const AppRadialActionButton({
    super.key,
    required this.actions,
    this.anchor = AppRadialActionAnchor.center,
  });

  final List<AppRadialAction> actions;
  final AppRadialActionAnchor anchor;

  @override
  State<AppRadialActionButton> createState() => _AppRadialActionButtonState();
}

class _AppRadialActionButtonState extends State<AppRadialActionButton>
    with SingleTickerProviderStateMixin {
  static const double _fabSize = 56;
  static const double _satelliteSize = 48;
  static const double _orbitRadius = 100;

  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _close() {
    if (!_isOpen) return;
    setState(() {
      _isOpen = false;
      _controller.reverse();
    });
  }

  void _onActionTap(VoidCallback onTap) {
    _close();
    onTap();
  }

  Alignment get _stackAlignment => switch (widget.anchor) {
        AppRadialActionAnchor.center => Alignment.bottomCenter,
        AppRadialActionAnchor.end => Alignment.bottomRight,
      };

  double get _width => switch (widget.anchor) {
        AppRadialActionAnchor.center => _orbitRadius * 2 + _fabSize,
        AppRadialActionAnchor.end => _orbitRadius + _fabSize,
      };

  ({double startAngle, double endAngle}) get _arcAngles =>
      switch (widget.anchor) {
        AppRadialActionAnchor.center => (startAngle: math.pi, endAngle: 0.0),
        AppRadialActionAnchor.end => (
            startAngle: math.pi,
            endAngle: math.pi * 1.5,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionCount = widget.actions.length;
    final arc = _arcAngles;
    final showSatellites = _isOpen || _controller.value > 0;

    return TapRegion(
      onTapOutside: (_) {
        if (_isOpen) {
          _toggle();
        }
      },
      child: SizedBox(
        width: _width,
        height: showSatellites ? _orbitRadius + _fabSize + AppSpacing.xl : _fabSize,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: _stackAlignment,
        children: [
          if (showSatellites)
            for (var i = 0; i < actionCount; i++)
              AnimatedBuilder(
                animation: _expandAnimation,
                builder: (context, child) {
                  final progress = _expandAnimation.value;
                  final motionProgress = progress.clamp(0.0, 1.0);
                  final angle = arc.startAngle +
                      (arc.endAngle - arc.startAngle) *
                          (i / (actionCount - 1).clamp(1, 999));
                  final dx = math.cos(angle) * _orbitRadius * motionProgress;
                  final dy = math.sin(angle) * _orbitRadius * motionProgress;
                  final edgeInset = (_fabSize - _satelliteSize) / 2;
                  final interactive = progress > 0.05;

                  final satellite = IgnorePointer(
                    ignoring: !interactive,
                    child: _animatedSatellite(progress, child),
                  );

                  return switch (widget.anchor) {
                    AppRadialActionAnchor.center => Positioned(
                        bottom: edgeInset - dy,
                        left: (_orbitRadius + _fabSize / 2) +
                            dx -
                            _satelliteSize / 2,
                        child: satellite,
                      ),
                    AppRadialActionAnchor.end => Positioned(
                        bottom: edgeInset - dy,
                        right: edgeInset - dx,
                        child: satellite,
                      ),
                  };
                },
                child: _SatelliteButton(
                  action: widget.actions[i],
                  onTap: () => _onActionTap(widget.actions[i].onTap),
                ),
              ),
          FloatingActionButton(
            onPressed: _toggle,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 6,
            shape: AppRadius.stadiumBorder,
            child: AnimatedRotation(
              turns: _isOpen ? 0.125 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.add, size: 28),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _animatedSatellite(double progress, Widget? child) {
    return Opacity(
      opacity: progress.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: progress.clamp(0.0, 1.15),
        child: child,
      ),
    );
  }
}

class _SatelliteButton extends StatelessWidget {
  const _SatelliteButton({
    required this.action,
    required this.onTap,
  });

  final AppRadialAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: action.label,
      child: Material(
        elevation: 4,
        shadowColor: theme.colorScheme.onSurface.withValues(alpha: 0.2),
        color: theme.colorScheme.surface,
        shape: AppRadius.stadiumBorder,
        child: InkWell(
          onTap: onTap,
          customBorder: AppRadius.stadiumBorder,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              action.icon,
              color: theme.colorScheme.onSurface,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
