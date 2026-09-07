enum AppThemeVariant {
  light,
  dark,
  solarized,
  custom,
}

extension AppThemeVariantStorage on AppThemeVariant {
  String get storageKey => name;

  static AppThemeVariant fromStorageKey(String? key) {
    return AppThemeVariant.values.firstWhere(
      (variant) => variant.name == key,
      orElse: () => AppThemeVariant.light,
    );
  }
}
