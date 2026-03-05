import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC quản lý toàn bộ xác thực người dùng
/// Sử dụng AuthRepository (MVVM) thay vì gọi FirebaseAuth trực tiếp
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  StreamSubscription<User?>? _authSubscription;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    // Lắng nghe thay đổi trạng thái auth từ Firebase
    _authSubscription = authRepository.authStateChanges().listen((user) {
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
      final user = authRepository.currentUser;
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });

    // Xử lý: Đăng nhập bằng Email
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final credential = await authRepository.signInWithEmail(
          email: event.email,
          password: event.password,
        );
        // Kiểm tra email đã xác minh chưa
        if (credential.user != null && !credential.user!.emailVerified) {
          // Gửi lại email xác minh
          await authRepository.sendEmailVerification();
          // Đăng xuất vì chưa xác minh
          await authRepository.signOut();
          emit(AuthEmailNotVerified(event.email));
          return;
        }
        // AuthStateChanged sẽ tự động emit AuthAuthenticated
      } on FirebaseAuthException catch (e) {
        emit(AuthError(_mapFirebaseError(e.code)));
        emit(AuthUnauthenticated());
      } catch (e) {
        emit(AuthError("Lỗi đăng nhập: ${e.toString()}"));
        emit(AuthUnauthenticated());
      }
    });

    // Xử lý: Đăng nhập bằng Google
    on<AuthLoginWithGoogleRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signInWithGoogle();
        // AuthStateChanged sẽ tự động emit AuthAuthenticated
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled) {
          // Người dùng hủy chọn tài khoản — quay về trạng thái cũ
          emit(AuthUnauthenticated());
          return;
        }
        emit(AuthError("Lỗi đăng nhập Google: ${e.toString()}"));
        emit(AuthUnauthenticated());
      } catch (e) {
        emit(AuthError("Lỗi đăng nhập Google: ${e.toString()}"));
        emit(AuthUnauthenticated());
      }
    });

    // Xử lý: Đăng ký
    on<AuthRegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.register(
          email: event.email,
          password: event.password,
        );
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
        await authRepository.signOut();
        // AuthStateChanged sẽ tự động emit AuthUnauthenticated
      } catch (e) {
        emit(AuthError("Lỗi đăng xuất: ${e.toString()}"));
      }
    });
  }

  /// Lấy user hiện tại (tiện lợi)
  User? get currentUser => authRepository.currentUser;

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
