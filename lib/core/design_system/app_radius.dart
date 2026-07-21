import 'package:flutter/material.dart';

abstract final class AppRadius {
  /// Large radius that produces pill-shaped corners on any practical widget size.
  static const double pill = 999;

  static const double sm = pill;
  static const double md = pill;
  static const double lg = pill;

  /// Pre-pill radii retained for onboarding/tutorial surfaces.
  static const double onboardingSm = 12;
  static const double onboardingMd = 16;
  static const double onboardingLg = 24;

  static const BorderRadius smBorder = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius mdBorder = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius lgBorder = BorderRadius.vertical(
    top: Radius.circular(pill),
  );

  static const BorderRadius onboardingSmBorder = BorderRadius.all(
    Radius.circular(onboardingSm),
  );
  static const BorderRadius onboardingMdBorder = BorderRadius.all(
    Radius.circular(onboardingMd),
  );
  static const BorderRadius onboardingLgBorder = BorderRadius.vertical(
    top: Radius.circular(onboardingLg),
  );

  static const StadiumBorder stadiumBorder = StadiumBorder();
  static const RoundedRectangleBorder pillShape = RoundedRectangleBorder(
    borderRadius: mdBorder,
  );
  static const RoundedRectangleBorder onboardingMdShape =
      RoundedRectangleBorder(borderRadius: onboardingMdBorder);
}
