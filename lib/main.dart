import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

// --- Repositories ---
import 'data/repositories/song_repository.dart';
import 'data/repositories/post_repository.dart';
import 'data/repositories/album_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'data/repositories/follow_repository.dart';
import 'data/repositories/auth_repository.dart';

// --- Data Providers ---
import 'data/dataproviders/db_helper.dart';

// --- BLoCs ---
import 'logic/song_bloc/song_bloc.dart';
import 'logic/song_list/song_list_bloc.dart';
import 'logic/song_list/song_list_event.dart';
import 'logic/auth_bloc/auth_bloc.dart';
import 'logic/player/player_bloc.dart';
import 'logic/favorites/favorites_bloc.dart';
import 'logic/favorites/favorites_event.dart';
import 'logic/feed/feed_bloc.dart';
import 'logic/album/album_bloc.dart';
import 'logic/banner/banner_bloc.dart';
import 'logic/banner/banner_event.dart';
import 'logic/profile/profile_bloc.dart';
import 'logic/profile/profile_event.dart';
import 'logic/history/history_bloc.dart';
import 'logic/history/history_event.dart';
import 'logic/settings/settings_bloc.dart';
import 'logic/settings/settings_state.dart';
import 'logic/notification/notification_bloc.dart';
import 'logic/notification/notification_event.dart';
import 'logic/follow/follow_bloc.dart';
import 'logic/follow/follow_event.dart';

// --- Localization ---
import 'l10n/app_localizations.dart';

// --- Screens ---
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'data/services/local_notification_service.dart';
import 'data/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Khởi tạo Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Khởi tạo Local Notification Service
  await LocalNotificationService.initialize();

  // 3. Khởi tạo Firebase Cloud Messaging
  await FcmService.initialize();

  // 4. Khởi tạo SharedPreferences cho SettingsBloc
  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    final dbHelper = DatabaseHelper();
    final followRepository = FollowRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => SongRepository()),
        RepositoryProvider(create: (_) => PostRepository()),
        RepositoryProvider(create: (_) => AlbumRepository()),
        RepositoryProvider(create: (_) => NotificationRepository()),
        RepositoryProvider(create: (_) => followRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          // Song BLoCs
          BlocProvider<SongListBloc>(
            create: (context) => SongListBloc(
              songRepository: context.read<SongRepository>(),
              authRepository: context.read<AuthRepository>(),
            )..add(SyncAndLoadSongs()),
          ),
          BlocProvider<SongBloc>(
            create: (context) => SongBloc(
              songRepository: context.read<SongRepository>(),
              notificationRepository: context.read<NotificationRepository>(),
              authRepository: context.read<AuthRepository>(),
            ),
          ),

          // Auth
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>()),
          ),

          // Player
          BlocProvider<PlayerBloc>(create: (_) => PlayerBloc()),

          // Favorites — persist vào SQLite
          BlocProvider<FavoritesBloc>(
            create: (_) =>
                FavoritesBloc(dbHelper: dbHelper)..add(LoadFavorites()),
          ),

          // History — persist vào SQLite
          BlocProvider<HistoryBloc>(
            create: (_) => HistoryBloc(dbHelper: dbHelper)..add(LoadHistory()),
          ),

          // Feed
          BlocProvider<FeedBloc>(
            create: (context) => FeedBloc(
              postRepository: context.read<PostRepository>(),
              notificationRepository: context.read<NotificationRepository>(),
              authRepository: context.read<AuthRepository>(),
            ),
          ),

          // Album
          BlocProvider<AlbumBloc>(
            create: (context) => AlbumBloc(
              albumRepository: context.read<AlbumRepository>(),
              authRepository: context.read<AuthRepository>(),
            ),
          ),

          // Banner
          BlocProvider<BannerBloc>(
            create: (_) => BannerBloc()..add(LoadBanners()),
          ),

          // Profile
          BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(
              songRepository: context.read<SongRepository>(),
              authRepository: context.read<AuthRepository>(),
            )..add(LoadProfile()),
          ),

          // Settings — persist vào SharedPreferences
          BlocProvider<SettingsBloc>(create: (_) => SettingsBloc(prefs: prefs)),

          // Notification
          BlocProvider<NotificationBloc>(
            create: (context) =>
                NotificationBloc(
                    notificationRepository: context
                        .read<NotificationRepository>(),
                    authRepository: context.read<AuthRepository>(),
                  )
                  ..add(LoadNotifications())
                  ..add(StartListeningNotifications()),
          ),

          // Follow — dùng FollowRepository (MVVM)
          BlocProvider<FollowBloc>(
            create: (context) => FollowBloc(
              followRepository: context.read<FollowRepository>(),
              authRepository: context.read<AuthRepository>(),
            )..add(LoadFollowing()),
          ),
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

  /// Theme tối
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
