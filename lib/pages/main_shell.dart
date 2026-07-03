import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/layout/main_shell_chrome.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/core/router/app_routes.dart';
import 'package:medicail/widget/buttons/app_radial_action_button.dart';
import 'package:medicail/widget/layout/app_bottom_nav_pill.dart';

class MainShell extends StatelessWidget {
  const MainShell({
    super.key,
    required this.child,
  });

  final Widget child;

  static EdgeInsets scrollPadding(BuildContext context) {
    return MainShellChrome.scrollPadding(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final location = GoRouterState.of(context).matchedLocation;

    final destinations = [
      AppBottomNavDestination(
        route: AppRoutes.home,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: l10n.navHome,
      ),
      AppBottomNavDestination(
        route: AppRoutes.patients,
        icon: Icons.folder_outlined,
        selectedIcon: Icons.folder,
        label: l10n.navPatients,
      ),
      AppBottomNavDestination(
        route: AppRoutes.settings,
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        label: l10n.navSettings,
      ),
    ];

    return MainShellScope(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: MediaQuery.removePadding(
                context: context,
                removeBottom: true,
                child: child,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: MainShellChrome.navLift,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.lg),
                        child: AppRadialActionButton(
                          anchor: AppRadialActionAnchor.end,
                          actions: [
                            AppRadialAction(
                              icon: Icons.folder_outlined,
                              label: l10n.radialActionPatients,
                              onTap: () => context.go(AppRoutes.patients),
                            ),
                            AppRadialAction(
                              icon: Icons.mic_outlined,
                              label: l10n.radialActionNewRecord,
                              onTap: () => context.goRecord(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Center(
                        child: AppBottomNavPill(
                          destinations: destinations,
                          selectedRoute: location,
                          onDestinationSelected: (route) => context.go(route),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
