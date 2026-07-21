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

class AppBottomNavPill extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 8,
      shadowColor: theme.colorScheme.onSurface.withValues(alpha: 0.15),
      shape: const StadiumBorder(),
      color: theme.colorScheme.surface,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: showLabels ? AppSpacing.sm : AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < destinations.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.xs),
              _buildNavItem(destinations[i], showLabels),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(AppBottomNavDestination dest, bool showLabels) {
    final item = _NavItem(
      destination: dest,
      isSelected: dest.route == selectedRoute,
      showLabel: showLabels,
      onTap: () => onDestinationSelected(dest.route),
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
    final foregroundColor =
        isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;
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
          constraints: BoxConstraints(minWidth: showLabel ? 72 : 44),
          padding: EdgeInsets.symmetric(
            horizontal: showLabel ? AppSpacing.md : AppSpacing.sm,
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
