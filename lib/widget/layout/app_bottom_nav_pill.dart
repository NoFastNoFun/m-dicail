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
  late List<GlobalKey> _itemKeys;
  int? _dragPreviewIndex;

  int get _selectedIndex =>
      indexOfBottomNavDestination(widget.destinations, widget.selectedRoute);

  @override
  void initState() {
    super.initState();
    _itemKeys = _keysForCount(widget.destinations.length);
  }

  @override
  void didUpdateWidget(AppBottomNavPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.destinations.length != widget.destinations.length) {
      _itemKeys = _keysForCount(widget.destinations.length);
    }
  }

  List<GlobalKey> _keysForCount(int count) {
    return List<GlobalKey>.generate(count, (_) => GlobalKey());
  }

  int _indexAtGlobalX(double globalX) {
    var bestIndex = 0;
    var bestDistance = double.infinity;
    for (var i = 0; i < _itemKeys.length; i++) {
      final box = _itemKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) {
        continue;
      }
      final origin = box.localToGlobal(Offset.zero);
      final centerX = origin.dx + box.size.width / 2;
      final distance = (globalX - centerX).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  void _setPreviewAt(double globalX) {
    final index = _indexAtGlobalX(globalX);
    if (_dragPreviewIndex == index) {
      return;
    }
    setState(() => _dragPreviewIndex = index);
  }

  void _onDragStart(DragStartDetails details) {
    _setPreviewAt(details.globalPosition.dx);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _setPreviewAt(details.globalPosition.dx);
  }

  void _onDragEnd(DragEndDetails details) {
    final index = _dragPreviewIndex;
    setState(() => _dragPreviewIndex = null);
    if (index == null ||
        index < 0 ||
        index >= widget.destinations.length ||
        index == _selectedIndex) {
      return;
    }
    widget.onDestinationSelected(widget.destinations[index].route);
  }

  void _onDragCancel() {
    if (_dragPreviewIndex == null) {
      return;
    }
    setState(() => _dragPreviewIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlightedIndex = _dragPreviewIndex ?? _selectedIndex;

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
        onHorizontalDragCancel: _onDragCancel,
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
                  child: KeyedSubtree(
                    key: _itemKeys[i],
                    child: _buildNavItem(
                      widget.destinations[i],
                      widget.showLabels,
                      i == highlightedIndex,
                    ),
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
