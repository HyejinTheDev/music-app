import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- LOGIC IMPORTS ---
import '../../logic/song_list/song_list_bloc.dart';
import '../../logic/song_list/song_list_state.dart';
import '../../logic/song_list/song_list_event.dart';
import '../../logic/player/player_bloc.dart';
import '../../logic/player/player_state.dart';
import '../../logic/player/player_event.dart';
import '../../logic/favorites/favorites_bloc.dart';
import '../../logic/favorites/favorites_state.dart';
import '../../logic/favorites/favorites_event.dart';
import '../../logic/feed/feed_bloc.dart';
import '../../logic/feed/feed_event.dart';
import '../../data/models/song_model.dart';
import '../../data/repositories/album_repository.dart';

// --- SCREENS & WIDGETS IMPORTS ---
import 'search_screens.dart';
import 'profile_screen.dart';
import 'feed_screen.dart';
import 'library_screen.dart';
import '../widgets/song_options_menu.dart';
import '../widgets/song_item.dart';
import '../widgets/mini_player.dart';
import '../widgets/promo_banner.dart';

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

  // --- HÀM XỬ LÝ MENU 3 CHẤM ---
  void _handleShowOptions(BuildContext context, Song song) {
    final favState = context.read<FavoritesBloc>().state;
    final playerBloc = context.read<PlayerBloc>();
    final playerState = playerBloc.state;

    showSongOptionsMenu(
      context: context,
      song: song,
      likedSongIds: favState.likedSongIds.toList(),
      favoriteSongs: favState.favoriteSongs.toList(),
      player: playerBloc.player,
      currentSong: playerState.currentSong,
      onStateChanged: () => setState(() {}),
      onClearCurrentSong: () => playerBloc.add(StopRequested()),
      onShareToFeed: (sharedSong, caption) {
        context.read<FeedBloc>().add(
          CreatePost(caption: caption, song: sharedSong),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
            context.read<PlayerBloc>().add(UpdatePlaylist(songListState.songs));

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
      _buildHomeContent(songListState, playerState),

      FeedScreen(
        player: context.read<PlayerBloc>().player,
        currentSong: playerState.currentSong,
        onPlaySong: _playMusic,
        favoriteSongs: favState.favoriteSongs.toList(),
        onToggleFavorite: (song) {
          context.read<FavoritesBloc>().add(ToggleFavorite(song));
        },
      ),

      SearchScreen(
        songs: songListState.songs,
        currentSong: playerState.currentSong,
        player: context.read<PlayerBloc>().player,
        onPlaySong: _playMusic,
        onOptionsTap: (song) => _handleShowOptions(context, song),
      ),

      LibraryScreen(
        favoriteSongs: favState.favoriteSongs.toList(),
        currentSong: playerState.currentSong,
        onPlaySong: _playMusic,
        onOptionsTap: (song) => _handleShowOptions(context, song),
      ),

      const ProfileScreen(),
    ];
  }

  // --- GIAO DIỆN TRANG CHỦ ---
  Widget _buildHomeContent(SongListLoaded state, PlayerState playerState) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2C3E50), Colors.black],
          stops: [0.0, 0.3],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              _buildSectionTitle("Nghệ sĩ nổi bật"),
              _buildArtistBanner(state.songs),
              const PromoBanner(),
              _buildSectionTitle("Gợi ý cho bạn"),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: min(10, state.songs.length),
                itemBuilder: (context, index) {
                  final song = state.songs[index];
                  return SongItem(
                    song: song,
                    isSelected: playerState.currentSong?.id == song.id,
                    onTap: () => _playMusic(song),
                    onOptionsTap: () => _handleShowOptions(context, song),
                  );
                },
              ),
              _buildSectionTitle("Album mới nhất"),
              _buildAlbumBanner(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Music App Pro",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<SongListBloc>().add(LoadSongs()),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF121212),
      selectedItemColor: Colors.tealAccent,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Feed'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_music),
          label: 'Library',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildArtistBanner(List<Song> songs) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: songs.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => _playMusic(songs[index]),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 80,
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(songs[index].coverUrl),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  songs[index].artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumBanner() {
    // Dùng AlbumRepository stream thay vì Firestore trực tiếp
    return SizedBox(
      height: 190,
      child: StreamBuilder(
        stream: context.read<AlbumRepository>().getAlbumsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.tealAccent),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Chưa có album nào",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            );
          }

          final albums = snapshot.data!.docs;

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final albumData = albums[index].data() as Map<String, dynamic>;
              final title = albumData['title'] ?? 'Không tên';
              final artist = albumData['artist'] ?? 'Nghệ sĩ';
              final coverUrl = albumData['coverUrl'] ?? '';

              return GestureDetector(
                onTap: () {
                  // Có thể mở trang chi tiết album ở đây sau này
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          coverUrl,
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.album,
                                  color: Colors.white54,
                                  size: 50,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
