import 'package:flutter/material.dart';

abstract final class AppRadius {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;

  static const BorderRadius smBorder = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdBorder = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgBorder = BorderRadius.vertical(
    top: Radius.circular(lg),
  );
}
