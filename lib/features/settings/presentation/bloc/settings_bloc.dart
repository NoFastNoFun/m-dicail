import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/features/settings/domain/repositories/user_preferences_repository.dart';
import 'package:medicail/features/settings/presentation/bloc/settings_event.dart';
import 'package:medicail/features/settings/presentation/bloc/settings_state.dart';
import 'package:medicail/features/settings/presentation/notifier/settings_notifier.dart';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(
    this._repository,
    this._settingsNotifier,
  ) : super(const SettingsInitial()) {
    on<SettingsLoadRequested>(_onLoadRequested);
    on<SettingsThemeChanged>(_onThemeChanged);
    on<SettingsFontScaleChanged>(_onFontScaleChanged);
    on<SettingsDefaultSessionLengthChanged>(_onDefaultSessionLengthChanged);
  }

  final UserPreferencesRepository _repository;
  final SettingsNotifier _settingsNotifier;

  Future<void> _onLoadRequested(
    SettingsLoadRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());

    final themeVariant = await _repository.readThemeVariant();
    final fontScale = await _repository.readFontScale();
    final defaultSessionLength = await _repository.readDefaultSessionLength();

    _settingsNotifier.setThemeVariant(themeVariant);
    _settingsNotifier.setFontScale(fontScale);
    _settingsNotifier.setDefaultSessionLength(defaultSessionLength);

    emit(SettingsLoaded(
      themeVariant: themeVariant,
      fontScale: fontScale,
      defaultSessionLength: defaultSessionLength,
    ));
  }

  Future<void> _onThemeChanged(
    SettingsThemeChanged event,
    Emitter<SettingsState> emit,
  ) async {
    await _repository.writeThemeVariant(event.variant);
    _settingsNotifier.setThemeVariant(event.variant);

    final current = state;
    if (current is SettingsLoaded) {
      emit(current.copyWith(themeVariant: event.variant));
    }
  }

  Future<void> _onFontScaleChanged(
    SettingsFontScaleChanged event,
    Emitter<SettingsState> emit,
  ) async {
    await _repository.writeFontScale(event.scale);
    _settingsNotifier.setFontScale(event.scale);

    final current = state;
    if (current is SettingsLoaded) {
      emit(current.copyWith(fontScale: event.scale));
    }
  }

  Future<void> _onDefaultSessionLengthChanged(
    SettingsDefaultSessionLengthChanged event,
    Emitter<SettingsState> emit,
  ) async {
    await _repository.writeDefaultSessionLength(event.length);
    _settingsNotifier.setDefaultSessionLength(event.length);

    final current = state;
    if (current is SettingsLoaded) {
      emit(current.copyWith(defaultSessionLength: event.length));
    }
  }
}
