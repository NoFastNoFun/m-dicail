import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/widget/app_text.dart';

class AppBottomNavDestination {
  const AppBottomNavDestination({
    required this.route,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.wrapper,
  });

  final String route;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  /// Optional callback that wraps the nav-item widget (e.g. with a Showcase).
  final Widget Function(Widget child)? wrapper;
}

/// Index of the destination that owns [location], including nested routes.
int indexOfBottomNavDestination(
  List<AppBottomNavDestination> destinations,
  String location,
) {
  var bestIndex = -1;
  var bestLength = -1;
  for (var i = 0; i < destinations.length; i++) {
    final route = destinations[i].route;
    final matches = location == route || location.startsWith('$route/');
    if (matches && route.length > bestLength) {
      bestIndex = i;
      bestLength = route.length;
    }
  }
  return bestIndex;
}

class AppBottomNavPill extends StatefulWidget {
  const AppBottomNavPill({
    super.key,
    required this.destinations,
    required this.selectedRoute,
    required this.onDestinationSelected,
    this.showLabels = true,
  });

  final List<AppBottomNavDestination> destinations;
  final String selectedRoute;
  final ValueChanged<String> onDestinationSelected;
  final bool showLabels;

  @override
  State<AppBottomNavPill> createState() => _AppBottomNavPillState();
}

class _AppBottomNavPillState extends State<AppBottomNavPill> {
  static const _minFlingVelocity = 240.0;
  static const _minDragDistance = 36.0;

  double _dragDx = 0;

  int get _selectedIndex =>
      indexOfBottomNavDestination(widget.destinations, widget.selectedRoute);

  void _onDragStart(DragStartDetails details) {
    _dragDx = 0;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _dragDx += details.delta.dx;
  }

  void _onDragEnd(DragEndDetails details) {
    final index = _selectedIndex;
    if (index < 0) {
      _dragDx = 0;
      return;
    }

    final velocity = details.primaryVelocity ?? 0;
    final dragDx = _dragDx;
    _dragDx = 0;

    final int? nextIndex;
    if (velocity.abs() >= _minFlingVelocity) {
      nextIndex = velocity < 0 ? index + 1 : index - 1;
    } else if (dragDx.abs() >= _minDragDistance) {
      nextIndex = dragDx < 0 ? index + 1 : index - 1;
    } else {
      nextIndex = null;
    }

    if (nextIndex == null ||
        nextIndex < 0 ||
        nextIndex >= widget.destinations.length) {
      return;
    }
    widget.onDestinationSelected(widget.destinations[nextIndex].route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedIndex = _selectedIndex;

    return Material(
      elevation: 8,
      shadowColor: theme.colorScheme.onSurface.withValues(alpha: 0.15),
      shape: const StadiumBorder(),
      color: theme.colorScheme.surface,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        onHorizontalDragCancel: () => _dragDx = 0,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: widget.showLabels ? AppSpacing.sm : AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < widget.destinations.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: _buildNavItem(
                    widget.destinations[i],
                    widget.showLabels,
                    i == selectedIndex,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    AppBottomNavDestination dest,
    bool showLabels,
    bool isSelected,
  ) {
    final item = _NavItem(
      destination: dest,
      isSelected: isSelected,
      showLabel: showLabels,
      onTap: () => widget.onDestinationSelected(dest.route),
    );
    return dest.wrapper != null ? dest.wrapper!(item) : item;
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.isSelected,
    required this.showLabel,
    required this.onTap,
  });

  final AppBottomNavDestination destination;
  final bool isSelected;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = isSelected
        ? theme.colorScheme.primary
        : Colors.transparent;
    final foregroundColor = isSelected
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;
    final mutedColor = theme.colorScheme.onSurface.withValues(alpha: 0.65);

    return Material(
      color: backgroundColor,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          constraints: BoxConstraints(minWidth: showLabel ? 56 : 44),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: showLabel ? AppSpacing.sm : AppSpacing.xs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? destination.selectedIcon : destination.icon,
                color: isSelected ? foregroundColor : mutedColor,
                size: 22,
              ),
              if (showLabel) ...[
                const SizedBox(height: AppSpacing.xs),
                AppText(
                  destination.label,
                  variant: AppTextVariant.caption,
                  color: isSelected ? foregroundColor : mutedColor,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
