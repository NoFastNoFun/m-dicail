import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/layout/main_shell_chrome.dart';
import 'package:medicail/core/utils/app_haptics.dart';
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
    this.showLabels = true,
    required this.onDestinationSelected,
  });

  final List<AppBottomNavDestination> destinations;
  final String selectedRoute;
  final bool showLabels;
  final ValueChanged<String> onDestinationSelected;

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
    _selectDestination(widget.destinations[index].route);
  }

  void _selectDestination(String route) {
    AppHaptics.tap();
    widget.onDestinationSelected(route);
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          height: MainShellChrome.navPillHeight(context, showLabels: widget.showLabels),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < widget.destinations.length; i++) ...[
                  Expanded(
                    child: KeyedSubtree(
                      key: _itemKeys[i],
                      child: _buildNavItem(
                        widget.destinations[i],
                        i == highlightedIndex,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(AppBottomNavDestination dest, bool isSelected) {
    final item = _NavItem(
      destination: dest,
      isSelected: isSelected,
      showLabels: widget.showLabels,
      onTap: () => _selectDestination(dest.route),
    );
    return dest.wrapper != null ? dest.wrapper!(item) : item;
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.isSelected,
    required this.showLabels,
    required this.onTap,
  });

  final AppBottomNavDestination destination;
  final bool isSelected;
  final bool showLabels;
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

    return Tooltip(
      message: destination.label,
      child: Semantics(
        selected: isSelected,
        child: Material(
          color: backgroundColor,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            customBorder: const StadiumBorder(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs / 2,
                vertical: AppSpacing.xs,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? destination.selectedIcon : destination.icon,
                    color: isSelected ? foregroundColor : mutedColor,
                    size: MainShellChrome.navIconSize,
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: showLabels
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: MainShellChrome.navLabelHeight(context),
                                child: Center(
                                  child: AppText(
                                    destination.label,
                                    variant: AppTextVariant.navigation,
                                    color: isSelected ? foregroundColor : mutedColor,
                                    textAlign: TextAlign.center,
                                    maxLines: MainShellChrome.navLabelMaxLines,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
