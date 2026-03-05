/// Các sự kiện quên mật khẩu
abstract class ForgotPasswordEvent {}

/// Yêu cầu gửi email đặt lại mật khẩu
class ForgotPasswordRequested extends ForgotPasswordEvent {
  final String email;

  ForgotPasswordRequested({required this.email});
}
