import 'package:firebase_auth/firebase_auth.dart';

/// Các sự kiện xác thực
abstract class AuthEvent {}

/// Kiểm tra trạng thái đăng nhập khi mở app
class AuthCheckRequested extends AuthEvent {}

/// Đăng nhập bằng email + mật khẩu
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested({required this.email, required this.password});
}

/// Đăng ký tài khoản mới
class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;

  AuthRegisterRequested({required this.email, required this.password});
}

/// Đăng nhập bằng Google
class AuthLoginWithGoogleRequested extends AuthEvent {}

/// Đăng xuất
class AuthLogoutRequested extends AuthEvent {}

/// Lắng nghe thay đổi trạng thái auth (auto-detect login/logout)
class AuthStateChanged extends AuthEvent {
  final User? user;

  AuthStateChanged(this.user);
}
