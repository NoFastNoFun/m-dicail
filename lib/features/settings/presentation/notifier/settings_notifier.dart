import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/features/settings/domain/entities/app_font_scale.dart';
import 'package:medicail/features/settings/domain/entities/app_theme_variant.dart';

@lazySingleton
class SettingsNotifier extends ChangeNotifier {
  AppThemeVariant _themeVariant = AppThemeVariant.light;
  AppFontScale _fontScale = AppFontScale.defaultScale;

  AppThemeVariant get themeVariant => _themeVariant;

  AppFontScale get fontScale => _fontScale;

  double get fontScaleMultiplier => _fontScale.multiplier;

  void setThemeVariant(AppThemeVariant variant) {
    if (_themeVariant != variant) {
      _themeVariant = variant;
      notifyListeners();
    }
  }

  void setFontScale(AppFontScale scale) {
    if (_fontScale != scale) {
      _fontScale = scale;
      notifyListeners();
    }
  }
}
