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
  final int followerCount;
  final int followingCount;

  ProfileLoaded({
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.followerCount = 0,
    this.followingCount = 0,
  });
}

/// Lỗi
class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}
