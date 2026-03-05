import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../logic/forgot_password_bloc/forgot_password_bloc.dart';
import '../../logic/forgot_password_bloc/forgot_password_event.dart';
import '../../logic/forgot_password_bloc/forgot_password_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ForgotPasswordBloc(authRepository: context.read<AuthRepository>()),
      child: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Đã gửi email đặt lại mật khẩu! Vui lòng kiểm tra hộp thư.",
                ),
                duration: Duration(seconds: 4),
              ),
            );
            Navigator.pop(context); // Quay lại LoginScreen
          } else if (state is ForgotPasswordError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text("Quên Mật Khẩu")),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const Icon(
                      Icons.lock_reset,
                      size: 80,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Nhập email đã đăng ký, chúng tôi sẽ gửi link đặt lại mật khẩu về hộp thư của bạn.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (val) => (val == null || val.isEmpty)
                          ? "Vui lòng nhập email"
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // Dùng BlocBuilder để hiện loading
                    BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
                      builder: (context, state) {
                        if (state is ForgotPasswordLoading) {
                          return const CircularProgressIndicator();
                        }
                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (!_formKey.currentState!.validate()) return;
                              context.read<ForgotPasswordBloc>().add(
                                ForgotPasswordRequested(
                                  email: _emailController.text.trim(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.send),
                            label: const Text("GỬI EMAIL ĐẶT LẠI MẬT KHẨU"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Quay lại đăng nhập"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
