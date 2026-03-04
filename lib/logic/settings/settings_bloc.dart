import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_event.dart';
import 'settings_state.dart';

/// BLoC quản lý chế độ sáng/tối + ngôn ngữ
/// Persist settings vào SharedPreferences để giữ khi tắt app
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences _prefs;

  static const _keyDarkMode = 'settings_dark_mode';
  static const _keyLocale = 'settings_locale';

  SettingsBloc({required SharedPreferences prefs})
    : _prefs = prefs,
      super(
        SettingsState(
          isDarkMode: prefs.getBool('settings_dark_mode') ?? true,
          locale: Locale(prefs.getString('settings_locale') ?? 'vi'),
        ),
      ) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetLocaleEvent>(_onSetLocale);
  }

  /// Load settings từ SharedPreferences
  void _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) {
    final isDarkMode = _prefs.getBool(_keyDarkMode) ?? true;
    final localeCode = _prefs.getString(_keyLocale) ?? 'vi';
    emit(SettingsState(isDarkMode: isDarkMode, locale: Locale(localeCode)));
  }

  /// Toggle theme và persist
  void _onToggleTheme(ToggleThemeEvent event, Emitter<SettingsState> emit) {
    final newDarkMode = !state.isDarkMode;
    _prefs.setBool(_keyDarkMode, newDarkMode);
    emit(state.copyWith(isDarkMode: newDarkMode));
  }

  /// Đặt locale và persist
  void _onSetLocale(SetLocaleEvent event, Emitter<SettingsState> emit) {
    _prefs.setString(_keyLocale, event.languageCode);
    emit(state.copyWith(locale: Locale(event.languageCode)));
  }
}
