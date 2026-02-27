import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/presentation/screens/home_screen.dart';
import 'firebase_options.dart';

// Import Repository
import 'data/repositories/song_repository.dart';

// Import Logic
import 'logic/song_bloc/song_bloc.dart';
import 'logic/song_list/song_list_bloc.dart';
import 'logic/song_list/song_list_event.dart';

// Import Screens
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart'; // Thêm import này nếu bạn có trang đăng ký

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => SongRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SongListBloc>(
            create: (context) => SongListBloc(
              songRepository: context.read<SongRepository>(),
            )..add(LoadSongs()),
          ),
          BlocProvider<SongBloc>(
            create: (context) => SongBloc(
              songRepository: context.read<SongRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Music App Pro',
          theme: ThemeData(
            brightness: Brightness.dark, // Chuyển toàn bộ App sang chế độ tối
            primarySwatch: Colors.teal,
            scaffoldBackgroundColor: Colors.black,
          ),

          // --- PHẦN QUAN TRỌNG NHẤT ĐỂ SỬA LỖI ĐĂNG XUẤT ---
          initialRoute: '/', // Điểm bắt đầu
          routes: {
            '/login': (context) => const LoginScreen(), // Khai báo tên '/login'
            // '/register': (context) => const RegisterScreen(), // Mở ra nếu bạn có trang này
            '/home': (context) => const HomeScreen(),
          },
          // -----------------------------------------------

          home: const LoginScreen(), // Màn hình mặc định khi mở App
        ),
      ),
    );
  }
}