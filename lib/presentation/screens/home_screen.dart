import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../l10n/app_localizations.dart';

// --- LOGIC IMPORTS ---
import '../../logic/song_list/song_list_bloc.dart';
import '../../logic/song_list/song_list_state.dart';
import '../../logic/player/player_bloc.dart';
import '../../logic/player/player_state.dart';
import '../../logic/player/player_event.dart';
import '../../logic/favorites/favorites_bloc.dart';
import '../../logic/favorites/favorites_state.dart';
import '../../logic/favorites/favorites_event.dart';
import '../../logic/history/history_bloc.dart';
import '../../logic/history/history_event.dart';

import '../../data/models/song_model.dart';

// --- SCREENS & WIDGETS IMPORTS ---
import 'search_screens.dart';
import 'profile_screen.dart';
import 'feed_screen.dart';
import 'library_screen.dart';
import '../widgets/mini_player.dart';
import '../widgets/home_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // --- HÀM PHÁT NHẠC QUA BLOC ---
  void _playMusic(Song song) {
    context.read<PlayerBloc>().add(PlaySongRequested(song));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerBloc, PlayerState>(
      listenWhen: (prev, curr) =>
          curr is PlayerPlaying && prev.currentSong?.id != curr.currentSong?.id,
      listener: (context, state) {
        if (state.currentSong != null) {
          context.read<HistoryBloc>().add(AddToHistory(state.currentSong!));
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        bottomNavigationBar: _buildBottomNavBar(),
        body: BlocBuilder<SongListBloc, SongListState>(
          builder: (context, songListState) {
            if (songListState is SongListLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.tealAccent),
              );
            }

            if (songListState is SongListLoaded) {
              // Cập nhật playlist cho PlayerBloc
              context.read<PlayerBloc>().add(
                UpdatePlaylist(songListState.songs),
              );

              return _buildMainContent(songListState);
            }

            if (songListState is SongListError) {
              return Center(
                child: Text(
                  "Lỗi: ${songListState.message}",
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(SongListLoaded songListState) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, playerState) {
        return BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, favState) {
            final currentSong = playerState.currentSong;

            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: currentSong != null ? 80 : 0,
                  ),
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _buildPages(songListState, playerState, favState),
                  ),
                ),
                if (currentSong != null)
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 10,
                    child: MiniPlayer(
                      song: currentSong,
                      player: context.read<PlayerBloc>().player,
                      isFavorite: favState.isFavorite(currentSong),
                      onToggleFavorite: () {
                        context.read<FavoritesBloc>().add(
                          ToggleFavorite(currentSong),
                        );
                      },
                      songs: songListState.songs,
                      onSongChanged: (newSong) => _playMusic(newSong),
                      onDismissed: () {
                        context.read<PlayerBloc>().add(StopRequested());
                      },
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  // --- CÁC TRANG TRONG BOTTOM NAV BAR ---
  List<Widget> _buildPages(
    SongListLoaded songListState,
    PlayerState playerState,
    FavoritesState favState,
  ) {
    return [
      HomeContent(
        songs: songListState.songs,
        currentSong: playerState.currentSong,
      ),

      FeedScreen(
        player: context.read<PlayerBloc>().player,
        currentSong: playerState.currentSong,
        onPlaySong: _playMusic,
        favoriteSongs: favState.favoriteSongs.toList(),
        onToggleFavorite: (song) {
          context.read<FavoritesBloc>().add(ToggleFavorite(song));
        },
      ),

      const SearchScreen(),

      const LibraryScreen(),

      const ProfileScreen(),
    ];
  }

  Widget _buildBottomNavBar() {
    final loc = AppLocalizations.of(context);
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Theme.of(
        context,
      ).bottomNavigationBarTheme.backgroundColor,
      selectedItemColor: Theme.of(
        context,
      ).bottomNavigationBarTheme.selectedItemColor,
      unselectedItemColor: Theme.of(
        context,
      ).bottomNavigationBarTheme.unselectedItemColor,
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: loc.translate('home'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.feed),
          label: loc.translate('feed'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.search),
          label: loc.translate('search'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.library_music),
          label: loc.translate('library'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: loc.translate('profile'),
        ),
      ],
    );
  }
}
