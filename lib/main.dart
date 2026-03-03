import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
import 'logic/profile/profile_bloc.dart';
import 'logic/profile/profile_event.dart';
import 'logic/history/history_bloc.dart';
import 'logic/settings/settings_bloc.dart';
import 'logic/settings/settings_state.dart';

// --- Localization ---
import 'l10n/app_localizations.dart';

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
          BlocProvider<HistoryBloc>(create: (_) => HistoryBloc()),
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
          BlocProvider<ProfileBloc>(
            create: (context) =>
                ProfileBloc(songRepository: context.read<SongRepository>())
                  ..add(LoadProfile()),
          ),

          // Settings BLoC — quản lý theme + locale
          BlocProvider<SettingsBloc>(create: (_) => SettingsBloc()),
        ],

        // Wrap MaterialApp bằng BlocBuilder để reactive theme/locale
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settings) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Music App Pro',

              // --- THEME ---
              theme: _buildLightTheme(),
              darkTheme: _buildDarkTheme(),
              themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,

              // --- LOCALIZATION ---
              locale: settings.locale,
              supportedLocales: const [Locale('vi'), Locale('en')],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],

              initialRoute: '/',
              routes: {
                '/login': (context) => const LoginScreen(),
                '/home': (context) => const HomeScreen(),
              },
              home: const LoginScreen(),
            );
          },
        ),
      ),
    );
  }

  /// Theme sáng
  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.teal,
      scaffoldBackgroundColor: Colors.grey[50],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
      ),
      cardColor: Colors.white,
      dividerColor: Colors.black12,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.light,
      ),
    );
  }

  /// Theme tối (giữ nguyên style cũ)
  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.teal,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF121212),
        selectedItemColor: Colors.tealAccent,
        unselectedItemColor: Colors.grey,
      ),
      cardColor: const Color(0xFF1E1E1E),
      dividerColor: Colors.white10,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.dark,
      ),
    );
  }
}
