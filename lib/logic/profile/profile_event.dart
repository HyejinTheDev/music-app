/// Các sự kiện quản lý profile
abstract class ProfileEvent {}

/// Tải thông tin profile người dùng hiện tại
class LoadProfile extends ProfileEvent {}

/// Cập nhật tên hiển thị (giữ lại để backward-compatible)
class UpdateDisplayName extends ProfileEvent {
  final String displayName;

  UpdateDisplayName(this.displayName);
}

/// Cập nhật profile: tên + ảnh (Firestore)
class UpdateProfile extends ProfileEvent {
  final String displayName;
  final String? photoUrl;

  UpdateProfile({required this.displayName, this.photoUrl});
}
