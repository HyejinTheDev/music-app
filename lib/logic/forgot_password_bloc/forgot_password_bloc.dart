import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/auth_repository.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final AuthRepository authRepository;

  ForgotPasswordBloc({required this.authRepository})
    : super(ForgotPasswordInitial()) {
    on<ForgotPasswordRequested>((event, emit) async {
      emit(ForgotPasswordLoading());
      try {
        await authRepository.sendPasswordResetEmail(email: event.email);
        emit(ForgotPasswordSent());
      } on FirebaseAuthException catch (e) {
        emit(ForgotPasswordError(_mapFirebaseError(e.code)));
      } catch (e) {
        emit(
          ForgotPasswordError(
            "Lỗi gửi email đặt lại mật khẩu: ${e.toString()}",
          ),
        );
      }
    });
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'too-many-requests':
        return 'Quá nhiều lần thử. Vui lòng thử lại sau';
      default:
        return 'Đã xảy ra lỗi: $code';
    }
  }
}
