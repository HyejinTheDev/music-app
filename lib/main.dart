import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';

// --- Repositories ---
import 'data/repositories/song_repository.dart';
import 'data/repositories/post_repository.dart';
import 'data/repositories/album_repository.dart';

// --- BLoCs ---
import 'logic/song_bloc/song_bloc.dart';
import 'logic/song_list/song_list_bloc.dart';
import 'logic/song_list/song_list_event.dart';
import 'logic/auth_bloc/auth_bloc.dart';
import 'logic/player/player_bloc.dart';
import 'logic/favorites/favorites_bloc.dart';
import 'logic/feed/feed_bloc.dart';
import 'logic/album/album_bloc.dart';
import 'logic/banner/banner_bloc.dart';
import 'logic/banner/banner_event.dart';

// --- Screens ---
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Khởi tạo Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => SongRepository()),
        RepositoryProvider(create: (_) => PostRepository()),
        RepositoryProvider(create: (_) => AlbumRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          // BLoCs giữ nguyên
          BlocProvider<SongListBloc>(
            create: (context) =>
                SongListBloc(songRepository: context.read<SongRepository>())
                  ..add(LoadSongs()),
          ),
          BlocProvider<SongBloc>(
            create: (context) =>
                SongBloc(songRepository: context.read<SongRepository>()),
          ),

          // BLoCs mới
          BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
          BlocProvider<PlayerBloc>(create: (_) => PlayerBloc()),
          BlocProvider<FavoritesBloc>(create: (_) => FavoritesBloc()),
          BlocProvider<FeedBloc>(
            create: (context) =>
                FeedBloc(postRepository: context.read<PostRepository>()),
          ),
          BlocProvider<AlbumBloc>(
            create: (context) =>
                AlbumBloc(albumRepository: context.read<AlbumRepository>()),
          ),
          BlocProvider<BannerBloc>(
            create: (_) => BannerBloc()..add(LoadBanners()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Music App Pro',
          theme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.teal,
            scaffoldBackgroundColor: Colors.black,
          ),
          initialRoute: '/',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
          },
          home: const LoginScreen(),
        ),
      ),
    );
  }
}
