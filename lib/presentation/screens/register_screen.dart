import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // Thêm ô nhập lại mật khẩu
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      if (mounted) {
        // Đăng ký xong thì báo thành công và quay lại trang đăng nhập
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng ký thành công! Vui lòng đăng nhập.")),
        );
        Navigator.pop(context); // Quay lại màn hình Login
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng Ký Tài Khoản")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Icon(Icons.person_add, size: 80, color: Colors.green),
                const SizedBox(height: 20),
                
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                  validator: (val) => val!.isEmpty ? "Vui lòng nhập Email" : null,
                ),
                const SizedBox(height: 10),
                
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: "Mật khẩu (tối thiểu 6 ký tự)", border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (val) => (val != null && val.length < 6) ? "Mật khẩu quá ngắn" : null,
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(labelText: "Nhập lại mật khẩu", border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (val) {
                    if (val != _passwordController.text) return "Mật khẩu không khớp";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          child: const Text("ĐĂNG KÝ NGAY"),
                        ),
                      ),
                
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Quay lại trang đăng nhập
                  },
                  child: const Text("Đã có tài khoản? Đăng nhập ngay"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}