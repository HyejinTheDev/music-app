/// Các trạng thái quên mật khẩu
abstract class ForgotPasswordState {}

/// Trạng thái ban đầu
class ForgotPasswordInitial extends ForgotPasswordState {}

/// Đang gửi email đặt lại mật khẩu
class ForgotPasswordLoading extends ForgotPasswordState {}

/// Đã gửi email thành công
class ForgotPasswordSent extends ForgotPasswordState {}

/// Xảy ra lỗi
class ForgotPasswordError extends ForgotPasswordState {
  final String message;

  ForgotPasswordError(this.message);
}
