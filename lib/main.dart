import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart'; // File này sinh ra lúc cài Firebase

// Import các file Logic và Data
import 'data/repositories/song_repository.dart';
import 'logic/song_bloc/song_bloc.dart';
import 'logic/song_bloc/song_event.dart';
import 'presentation/screens/login_screen.dart';

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
    // 2. Cung cấp Repository và Bloc cho toàn App
    return RepositoryProvider(
      create: (context) => SongRepository(),
      child: BlocProvider(
        create: (context) => SongBloc(
          songRepository: RepositoryProvider.of<SongRepository>(context),
        )..add(LoadSongs()), // Load nhạc từ SQLite ngay khi mở App
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Music App',
          theme: ThemeData(primarySwatch: Colors.blue),
          // Mở màn hình Đăng nhập đầu tiên
          home: const LoginScreen(), 
        ),
      ),
    );
  }
}