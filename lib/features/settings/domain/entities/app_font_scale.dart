enum AppFontScale {
  small,
  defaultScale,
  large,
  extraLarge,
}

extension AppFontScaleStorage on AppFontScale {
  String get storageKey => switch (this) {
        AppFontScale.small => 'small',
        AppFontScale.defaultScale => 'default',
        AppFontScale.large => 'large',
        AppFontScale.extraLarge => 'extra_large',
      };

  double get multiplier => switch (this) {
        AppFontScale.small => 0.85,
        AppFontScale.defaultScale => 1.0,
        AppFontScale.large => 1.15,
        AppFontScale.extraLarge => 1.30,
      };

  static AppFontScale fromStorageKey(String? key) {
    return AppFontScale.values.firstWhere(
      (scale) => scale.storageKey == key,
      orElse: () => AppFontScale.defaultScale,
    );
  }
}
