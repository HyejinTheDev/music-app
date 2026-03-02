/// Các trạng thái của profile
abstract class ProfileState {}

/// Chưa tải
class ProfileInitial extends ProfileState {}

/// Đang xử lý
class ProfileLoading extends ProfileState {}

/// Đã tải xong thông tin profile
class ProfileLoaded extends ProfileState {
  final String displayName;
  final String email;
  final String? photoUrl;

  ProfileLoaded({
    required this.displayName,
    required this.email,
    this.photoUrl,
  });
}

/// Lỗi
class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}
