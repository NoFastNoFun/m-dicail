import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/layout/main_shell_chrome.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/layout/app_bottom_nav_pill.dart';

/// Desktop side navigation.
///
/// Prefer this over [NavigationRail]: Material's rail has had recurring
/// mouse-tracker / hit-test failures on desktop that freeze pointer input.
class AppSideNavRail extends StatelessWidget {
  const AppSideNavRail({
    super.key,
    required this.destinations,
    required this.selectedRoute,
    required this.onDestinationSelected,
  });

  final List<AppBottomNavDestination> destinations;
  final String selectedRoute;
  final ValueChanged<String> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        right: false,
        child: SizedBox(
          width: MainShellChrome.sideRailWidth,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            children: [
              for (final dest in destinations)
                _buildItem(context, dest, dest.route == selectedRoute),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    AppBottomNavDestination dest,
    bool selected,
  ) {
    final item = _SideNavItem(
      destination: dest,
      selected: selected,
      onTap: () => onDestinationSelected(dest.route),
    );
    return dest.wrapper != null ? dest.wrapper!(item) : item;
  }
}

class _SideNavItem extends StatelessWidget {
  const _SideNavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final AppBottomNavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = theme.colorScheme.primary;
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.65);
    final fg = selected ? active : muted;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Material(
        color: selected
            ? active.withValues(alpha: 0.16)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    selected ? destination.selectedIcon : destination.icon,
                    color: fg,
                    size: 22,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppText(
                    destination.label,
                    variant: AppTextVariant.caption,
                    color: fg,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
