import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// State cho Settings: chứa chế độ sáng/tối + ngôn ngữ
class SettingsState extends Equatable {
  final bool isDarkMode;
  final Locale locale;

  const SettingsState({
    this.isDarkMode = true,
    this.locale = const Locale('vi'),
  });

  SettingsState copyWith({bool? isDarkMode, Locale? locale}) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => [isDarkMode, locale];
}
