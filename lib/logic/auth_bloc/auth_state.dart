import 'package:firebase_auth/firebase_auth.dart';

/// Các trạng thái xác thực
abstract class AuthState {}

/// Chưa xác định (đang kiểm tra)
class AuthInitial extends AuthState {}

/// Đang xử lý (loading)
class AuthLoading extends AuthState {}

/// Đã đăng nhập thành công
class AuthAuthenticated extends AuthState {
  final User user;

  AuthAuthenticated(this.user);
}

/// Chưa đăng nhập
class AuthUnauthenticated extends AuthState {}

/// Đăng ký thành công (chuyển về trang login)
class AuthRegisterSuccess extends AuthState {}

/// Xảy ra lỗi
class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}
