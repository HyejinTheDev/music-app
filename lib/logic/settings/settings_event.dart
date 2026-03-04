/// Các sự kiện cho Settings BLoC
abstract class SettingsEvent {}

/// Tải settings từ SharedPreferences khi khởi động
class LoadSettings extends SettingsEvent {}

/// Đổi giữa Dark <-> Light mode
class ToggleThemeEvent extends SettingsEvent {}

/// Đặt ngôn ngữ mới (vi / en)
class SetLocaleEvent extends SettingsEvent {
  final String languageCode;

  SetLocaleEvent(this.languageCode);
}
