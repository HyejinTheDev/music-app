import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../logic/song_list/song_list_bloc.dart';
import '../../logic/song_list/song_list_event.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  /// Đăng nhập bằng Email + Mật khẩu
  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      _goToHome();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi đăng nhập: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Đăng nhập bằng Google (Gmail)
  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
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
      await FirebaseAuth.instance.signInWithCredential(credential);

      _goToHome();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // Người dùng hủy chọn tài khoản
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi đăng nhập Google: ${e.toString()}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi đăng nhập Google: ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Chuyển đến HomeScreen sau khi đăng nhập thành công
  void _goToHome() {
    if (!mounted) return;
    // Sync bài hát từ Firebase về SQLite (quan trọng khi cài lại app)
    context.read<SongListBloc>().add(SyncAndLoadSongs());

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng Nhập")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              const Icon(Icons.music_note, size: 80, color: Colors.blue),
              const SizedBox(height: 20),

              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "Mật khẩu",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),

              _isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        // Nút đăng nhập Email
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("ĐĂNG NHẬP"),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Dòng chia "hoặc"
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[400])),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                "hoặc",
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey[400])),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Nút đăng nhập bằng Google
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: _loginWithGoogle,
                            icon: Image.network(
                              'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                              width: 24,
                              height: 24,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.g_mobiledata,
                                size: 28,
                                color: Colors.red,
                              ),
                            ),
                            label: const Text(
                              "Đăng nhập bằng Google",
                              style: TextStyle(fontSize: 16),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Chưa có tài khoản?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text("Đăng ký ngay"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
