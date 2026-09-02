import 'package:flutter/material.dart';

abstract final class AppRadius {
  /// Large radius that produces pill-shaped corners on buttons and chips.
  static const double pill = 999;

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;

  static const double xxl = 28;

  /// Softened radii for onboarding/tutorial surfaces.
  static const double onboardingSm = 12;
  static const double onboardingMd = 16;
  static const double onboardingLg = 24;

  static const BorderRadius smBorder = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdBorder = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgBorder = BorderRadius.vertical(
    top: Radius.circular(lg),
  );
  static const BorderRadius xxlBorder = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius pillBorder = BorderRadius.all(
    Radius.circular(pill),
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
    borderRadius: pillBorder,
  );
  static const RoundedRectangleBorder onboardingMdShape =
      RoundedRectangleBorder(borderRadius: onboardingMdBorder);
}
