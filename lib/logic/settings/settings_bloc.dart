import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';

/// BLoC quản lý chế độ sáng/tối + ngôn ngữ
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetLocaleEvent>(_onSetLocale);
  }

  void _onToggleTheme(ToggleThemeEvent event, Emitter<SettingsState> emit) {
    emit(state.copyWith(isDarkMode: !state.isDarkMode));
  }

  void _onSetLocale(SetLocaleEvent event, Emitter<SettingsState> emit) {
    emit(state.copyWith(locale: Locale(event.languageCode)));
  }
}
