import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:showcaseview/showcaseview.dart';

/// Tutorial/onboarding showcase with full-contrast tooltip and overlay colors.
class AppShowcase extends StatelessWidget {
  const AppShowcase({
    required GlobalKey key,
    required this.child,
    this.title,
    this.description,
    this.disposeOnTap,
    this.disableBarrierInteraction,
    this.onTargetClick,
    this.onBarrierClick,
  })  : showcaseKey = key,
        super(key: key);

  final GlobalKey showcaseKey;
  final Widget child;
  final String? title;
  final String? description;
  final bool? disposeOnTap;
  final bool? disableBarrierInteraction;
  final VoidCallback? onTargetClick;
  final VoidCallback? onBarrierClick;

  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: showcaseKey,
      title: title,
      description: description,
      disposeOnTap: disposeOnTap,
      disableBarrierInteraction: disableBarrierInteraction ?? false,
      onTargetClick: onTargetClick,
      onBarrierClick: onBarrierClick,
      overlayColor: AppColors.highContrastBlack,
      tooltipBackgroundColor: AppColors.highContrastWhite,
      textColor: AppColors.highContrastBlack,
      targetBorderRadius: AppRadius.onboardingMdBorder,
      tooltipBorderRadius: AppRadius.onboardingSmBorder,
      targetShapeBorder: AppRadius.onboardingMdShape,
      child: Theme(
        data: Theme.of(context).withOnboardingShapes,
        child: child,
      ),
    );
  }
}
