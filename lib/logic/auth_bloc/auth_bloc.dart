import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC quản lý toàn bộ xác thực người dùng
/// Tập trung logic từ login_screen.dart, register_screen.dart, profile_screen.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSubscription;

  AuthBloc() : super(AuthInitial()) {
    // Lắng nghe thay đổi trạng thái auth từ Firebase
    _authSubscription = _firebaseAuth.authStateChanges().listen((user) {
      add(AuthStateChanged(user));
    });

    // Xử lý: Auth state thay đổi (auto-detect)
    on<AuthStateChanged>((event, emit) {
      if (event.user != null) {
        emit(AuthAuthenticated(event.user!));
      } else {
        emit(AuthUnauthenticated());
      }
    });

    // Xử lý: Kiểm tra trạng thái đăng nhập
    on<AuthCheckRequested>((event, emit) {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });

    // Xử lý: Đăng nhập
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _firebaseAuth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        // AuthStateChanged sẽ tự động emit AuthAuthenticated
      } on FirebaseAuthException catch (e) {
        emit(AuthError(_mapFirebaseError(e.code)));
        emit(AuthUnauthenticated());
      } catch (e) {
        emit(AuthError("Lỗi đăng nhập: ${e.toString()}"));
        emit(AuthUnauthenticated());
      }
    });

    // Xử lý: Đăng ký
    on<AuthRegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _firebaseAuth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        // Đăng ký xong → đăng xuất để user tự đăng nhập lại
        await _firebaseAuth.signOut();
        emit(AuthRegisterSuccess());
        emit(AuthUnauthenticated());
      } on FirebaseAuthException catch (e) {
        emit(AuthError(_mapFirebaseError(e.code)));
        emit(AuthUnauthenticated());
      } catch (e) {
        emit(AuthError("Lỗi đăng ký: ${e.toString()}"));
        emit(AuthUnauthenticated());
      }
    });

    // Xử lý: Đăng xuất
    on<AuthLogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _firebaseAuth.signOut();
        // AuthStateChanged sẽ tự động emit AuthUnauthenticated
      } catch (e) {
        emit(AuthError("Lỗi đăng xuất: ${e.toString()}"));
      }
    });
  }

  /// Lấy user hiện tại (tiện lợi)
  User? get currentUser => _firebaseAuth.currentUser;

  /// Map mã lỗi Firebase sang thông báo tiếng Việt
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này';
      case 'wrong-password':
        return 'Mật khẩu không đúng';
      case 'email-already-in-use':
        return 'Email đã được sử dụng';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'too-many-requests':
        return 'Quá nhiều lần thử. Vui lòng thử lại sau';
      default:
        return 'Đã xảy ra lỗi: $code';
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
