import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

// --- THÊM 2 IMPORT FIREBASE VÀO ĐÂY ---
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- LOGIC IMPORTS ---
import '../../logic/song_list/song_list_bloc.dart';
import '../../logic/song_list/song_list_state.dart';
import '../../logic/song_list/song_list_event.dart';
import '../../logic/song_bloc/song_bloc.dart';
import '../../logic/song_bloc/song_event.dart' hide LoadSongs;
import '../../data/models/song_model.dart';

// --- SCREENS & WIDGETS IMPORTS ---
import 'search_screens.dart';
import 'profile_screen.dart';
import 'feed_screen.dart';
import 'library_screen.dart';
import '../widgets/song_options_menu.dart';
import '../widgets/song_item.dart';
import '../widgets/mini_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Máy phát nhạc chính của toàn ứng dụng
  final AudioPlayer _player = AudioPlayer();
  int _selectedIndex = 0;
  Song? _currentSong;

  // --- NƠI ĐỰNG DỮ LIỆU TẠM THỜI ---
  final List<String> _likedSongIds = []; // Chú ý: Đây phải là List<String> nha
  final List<Song> _favoriteSongs = [];
  // GHI CHÚ: Đã xóa _feedPosts vì bây giờ FeedScreen sẽ tự động lấy dữ liệu từ Firebase

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playMusic(Song song) async {
    try {
      if (_currentSong?.id == song.id) {
        if (_player.playing)
          _player.pause();
        else
          _player.play();
        return;
      }
      setState(() => _currentSong = song);
      await _player.stop();
      if (song.audioUrl.isNotEmpty) {
        await _player.setUrl(song.audioUrl);
        _player.play();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  // --- HÀM XỬ LÝ MENU 3 CHẤM NÂNG CẤP (FIREBASE) ---
  void _handleShowOptions(BuildContext context, Song song) {
    showSongOptionsMenu(
      context: context,
      song: song,
      likedSongIds: _likedSongIds,
      favoriteSongs: _favoriteSongs,
      player: _player,
      currentSong: _currentSong,
      onStateChanged: () => setState(() {}),
      onClearCurrentSong: () => setState(() => _currentSong = null),

      // BẮN BÀI VIẾT LÊN ĐÁM MÂY FIRESTORE THAY VÌ LƯU Ở RAM
      onShareToFeed: (sharedSong, caption) async {
        // 1. Lấy thông tin người dùng đang đăng nhập
        final user = FirebaseAuth.instance.currentUser;

        try {
          // 2. Gửi gói dữ liệu lên collection 'posts' của Firestore
          await FirebaseFirestore.instance.collection('posts').add({
            'userName': user?.displayName ?? "Người dùng ẩn danh",
            'userAvatar': user?.photoURL ?? "https://i.pravatar.cc/150?img=12",
            'caption': caption,
            'timestamp':
                FieldValue.serverTimestamp(), // Firestore tự gắn giờ thực tế
            'likes': 0,
            'comments': 0,
            // Lưu kèm thông tin bài hát để máy khác đọc được
            'songId': sharedSong.id,
            'songTitle': sharedSong.title,
            'songArtist': sharedSong.artist,
            'songCoverUrl': sharedSong.coverUrl,
            'songAudioUrl': sharedSong.audioUrl,
          });

          // Đã xóa hàm setState _feedPosts.add vì không cần nữa
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Lỗi đăng bài: $e")));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: _buildBottomNavBar(),
      body: BlocBuilder<SongListBloc, SongListState>(
        builder: (context, state) {
          if (state is SongListLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.tealAccent),
            );
          }

          if (state is SongListLoaded) {
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: _currentSong != null ? 80 : 0,
                  ),
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _buildPages(state),
                  ),
                ),
                if (_currentSong != null)
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 10,
                    child: MiniPlayer(
                      song: _currentSong!,
                      player: _player,
                      isFavorite: _likedSongIds.contains(
                        _currentSong!.id.toString(),
                      ),
                      onToggleFavorite: () {
                        setState(() {
                          final songIdStr = _currentSong!.id.toString();
                          if (_likedSongIds.contains(songIdStr)) {
                            _likedSongIds.remove(songIdStr);
                            _favoriteSongs.removeWhere(
                              (s) => s.id == _currentSong!.id,
                            );
                          } else {
                            _likedSongIds.add(songIdStr);
                            _favoriteSongs.add(_currentSong!);
                          }
                        });
                      },
                      onDismissed: () {
                        _player.stop();
                        setState(() => _currentSong = null);
                      },
                    ),
                  ),
              ],
            );
          }
          if (state is SongListError)
            return Center(
              child: Text(
                "Lỗi: ${state.message}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // --- CÁC TRANG TRONG BOTTOM NAV BAR ---
  List<Widget> _buildPages(SongListLoaded state) {
    return [
      _buildHomeContent(state),

      // FeedScreen giờ tự đọc bài viết từ Firestore, không cần truyền posts nữa
      FeedScreen(
        player: _player,
        currentSong: _currentSong,
        onPlaySong: _playMusic,
        favoriteSongs: _favoriteSongs,
        onToggleFavorite: (song) {
          setState(() {
            if (_favoriteSongs.contains(song)) {
              _favoriteSongs.remove(song);
            } else {
              _favoriteSongs.add(song);
            }
          });
        },
      ),

      SearchScreen(
        songs: state.songs,
        currentSong: _currentSong,
        player: _player,
        onPlaySong: _playMusic,
        onOptionsTap: (song) => _handleShowOptions(context, song),
      ),
      LibraryScreen(
        favoriteSongs: _favoriteSongs,
        currentSong: _currentSong,
        onPlaySong: _playMusic,
        onOptionsTap: (song) => _handleShowOptions(context, song),
      ),
      const ProfileScreen(),
    ];
  }

  // --- GIAO DIỆN TRANG CHỦ ---
  Widget _buildHomeContent(SongListLoaded state) {
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
              _buildSectionTitle("Album mới nhất"),
              _buildAlbumBanner(state.songs),
              _buildSectionTitle("Gợi ý cho bạn"),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: state.songs.length,
                itemBuilder: (context, index) {
                  final song = state.songs[index];
                  return SongItem(
                    song: song,
                    isSelected: _currentSong?.id == song.id,
                    onTap: () => _playMusic(song),
                    onOptionsTap: () => _handleShowOptions(context, song),
                  );
                },
              ),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Xem tất cả",
            style: TextStyle(color: Colors.tealAccent, fontSize: 14),
          ),
        ],
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

  Widget _buildAlbumBanner(List<Song> songs) {
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: songs.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => _playMusic(songs[index]),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    songs[index].coverUrl,
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  songs[index].title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  songs[index].artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
