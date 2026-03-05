import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Repository đóng gói toàn bộ thao tác xác thực
/// Screen → BLoC → AuthRepository → FirebaseAuth / GoogleSignIn
class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Lấy user hiện tại
  User? get currentUser => _firebaseAuth.currentUser;

  /// Kiểm tra email đã xác minh chưa
  bool get isEmailVerified => _firebaseAuth.currentUser?.emailVerified ?? false;

  /// Gửi email xác minh
  Future<void> sendEmailVerification() async {
    await _firebaseAuth.currentUser?.sendEmailVerification();
  }

  /// Stream theo dõi thay đổi trạng thái auth
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  /// Đăng nhập bằng Email + Mật khẩu
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Đăng nhập bằng Google
  Future<UserCredential> signInWithGoogle() async {
    // Bước 1: Khởi tạo GoogleSignIn (v7 sử dụng singleton)
    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(
      serverClientId:
          '71696684032-jgnjneddekabcbbkb8ni5j4mthjnt4ck.apps.googleusercontent.com',
    );

    // Bước 2: Mở popup chọn tài khoản Google
    final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

    // Bước 3: Lấy thông tin xác thực từ Google
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    // Bước 4: Tạo credential cho Firebase
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    // Bước 5: Đăng nhập Firebase bằng credential
    return await _firebaseAuth.signInWithCredential(credential);
  }

  /// Đăng ký tài khoản mới
  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Gửi email xác minh trước khi đăng xuất
    await credential.user?.sendEmailVerification();
    // Đăng ký xong → đăng xuất để user xác minh email rồi đăng nhập lại
    await _firebaseAuth.signOut();
    return credential;
  }

  /// Gửi email đặt lại mật khẩu
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Đăng xuất
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
