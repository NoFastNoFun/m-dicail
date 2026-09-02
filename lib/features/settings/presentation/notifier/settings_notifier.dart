import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/features/settings/domain/entities/app_font_scale.dart';
import 'package:medicail/features/settings/domain/entities/app_session_length.dart';
import 'package:medicail/features/settings/domain/entities/app_theme_variant.dart';
import 'package:medicail/features/settings/domain/repositories/user_preferences_repository.dart';

@lazySingleton
class SettingsNotifier extends ChangeNotifier {
  AppThemeVariant _themeVariant = AppThemeVariant.light;
  AppFontScale _fontScale = AppFontScale.defaultScale;
  AppSessionLength _defaultSessionLength = AppSessionLengthStorage.defaultLength;

  AppThemeVariant get themeVariant => _themeVariant;

  AppFontScale get fontScale => _fontScale;

  AppSessionLength get defaultSessionLength => _defaultSessionLength;

  Duration get defaultSessionDuration => _defaultSessionLength.duration;

  double get fontScaleMultiplier => _fontScale.multiplier;

  Future<void> hydrate(UserPreferencesRepository repository) async {
    try {
      _themeVariant = await repository.readThemeVariant();
      _fontScale = await repository.readFontScale();
      _defaultSessionLength = await repository.readDefaultSessionLength();
    } catch (_) {
      // Keep defaults if secure storage is unavailable.
    }
  }

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

  void setDefaultSessionLength(AppSessionLength length) {
    if (_defaultSessionLength != length) {
      _defaultSessionLength = length;
      notifyListeners();
    }
  }
}
