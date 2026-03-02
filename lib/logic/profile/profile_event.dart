/// Các sự kiện quản lý profile
abstract class ProfileEvent {}

/// Tải thông tin profile người dùng hiện tại
class LoadProfile extends ProfileEvent {}

/// Cập nhật tên hiển thị
class UpdateDisplayName extends ProfileEvent {
  final String displayName;

  UpdateDisplayName(this.displayName);
}
