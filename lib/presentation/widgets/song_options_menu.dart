import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- Imports Logic ---
import '../../data/models/song_model.dart';
import '../../logic/song_list/song_list_bloc.dart';
import '../../logic/song_list/song_list_event.dart';
import '../../logic/song_bloc/song_bloc.dart';
import '../../logic/song_bloc/song_event.dart' hide LoadSongs;
import '../../logic/favorites/favorites_bloc.dart';
import '../../logic/favorites/favorites_event.dart';
import '../../logic/favorites/favorites_state.dart';
import '../../logic/player/player_bloc.dart';
import '../../logic/player/player_event.dart';
import '../../logic/feed/feed_bloc.dart';
import '../../logic/feed/feed_event.dart';
import '../screens/add_edit_song_screen.dart';
import 'share_bottom_sheet.dart';
import 'song_info_dialog.dart';
import '../../logic/follow/follow_bloc.dart';
import '../../logic/follow/follow_event.dart';
import '../../logic/follow/follow_state.dart';

/// Hàm chính gọi Menu tùy chọn bài hát
void showSongOptionsMenu({
  required BuildContext context,
  required Song song,
  List<String>? likedSongIds,
  List<Song>? favoriteSongs,
  VoidCallback? onStateChanged,
}) {
  // Đọc từ BLoC nếu không truyền vào
  final favState = context.read<FavoritesBloc>().state;
  final effectiveLikedIds =
      likedSongIds ??
      (favState is FavoritesLoaded
          ? favState.likedSongIds.toList()
          : <String>[]);
  final effectiveFavSongs =
      favoriteSongs ??
      (favState is FavoritesLoaded
          ? favState.favoriteSongs.toList()
          : <Song>[]);
  final playerBloc = context.read<PlayerBloc>();
  final playerState = playerBloc.state;
  final player = playerBloc.player;
  final currentSong = playerState.currentSong;
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1E1E1E),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final songIdStr = song.id?.toString() ?? '';
            final isLiked = effectiveLikedIds.contains(songIdStr);
            final isInPlaylist = effectiveFavSongs.contains(song);

            return SingleChildScrollView(
              child: Wrap(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        song.coverUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      song.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      song.artist,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1),

                  ListTile(
                    leading: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.redAccent : Colors.white,
                    ),
                    title: Text(
                      isLiked ? 'Đã thích' : 'Thích bài hát',
                      style: TextStyle(
                        color: isLiked ? Colors.redAccent : Colors.white,
                      ),
                    ),
                    onTap: () {
                      context.read<FavoritesBloc>().add(ToggleFavorite(song));
                      Navigator.pop(context);
                    },
                  ),

                  ListTile(
                    leading: Icon(
                      isInPlaylist
                          ? Icons.playlist_add_check
                          : Icons.playlist_add,
                      color: isInPlaylist ? Colors.tealAccent : Colors.white,
                    ),
                    title: Text(
                      isInPlaylist ? 'Xóa khỏi Playlist' : 'Thêm vào Playlist',
                      style: TextStyle(
                        color: isInPlaylist ? Colors.tealAccent : Colors.white,
                      ),
                    ),
                    onTap: () {
                      context.read<FavoritesBloc>().add(ToggleFavorite(song));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isInPlaylist
                                ? "Đã xóa khỏi Thư viện"
                                : "Đã thêm vào Thư viện",
                          ),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.share, color: Colors.white),
                    title: const Text(
                      'Chia sẻ lên Cộng đồng (Feed)',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      final feedBloc = context.read<FeedBloc>();
                      final navContext = Navigator.of(context).context;
                      Navigator.pop(context);
                      showShareBottomSheet(navContext, song, (
                        sharedSong,
                        caption,
                      ) {
                        feedBloc.add(
                          CreatePost(caption: caption, song: sharedSong),
                        );
                      });
                    },
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'Thông tin ca sĩ / sáng tác',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showAuthorInfoDialog(context, song);
                    },
                  ),

                  // --- THEO DÕI NGHỆ SĨ (chỉ hiện khi không phải mình) ---
                  if (song.userId != null && song.userId != currentUserId)
                    BlocBuilder<FollowBloc, FollowState>(
                      builder: (context, followState) {
                        final isFollowing = followState.isFollowing(
                          song.userId!,
                        );
                        return ListTile(
                          leading: Icon(
                            isFollowing
                                ? Icons.person_remove
                                : Icons.person_add,
                            color: isFollowing
                                ? Colors.orangeAccent
                                : Colors.tealAccent,
                          ),
                          title: Text(
                            isFollowing
                                ? 'Bỏ theo dõi ${song.uploaderName ?? song.artist}'
                                : 'Theo dõi ${song.uploaderName ?? song.artist}',
                            style: TextStyle(
                              color: isFollowing
                                  ? Colors.orangeAccent
                                  : Colors.tealAccent,
                            ),
                          ),
                          onTap: () {
                            context.read<FollowBloc>().add(
                              ToggleFollow(
                                artistUserId: song.userId!,
                                artistName: song.uploaderName ?? song.artist,
                              ),
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isFollowing
                                      ? 'Đã bỏ theo dõi ${song.uploaderName ?? song.artist}'
                                      : 'Đã theo dõi ${song.uploaderName ?? song.artist}',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),

                  // --- CHỈ HIỆN SỬA/XÓA KHI LÀ CHỦ BÀI HÁT ---
                  if (song.userId != null &&
                      FirebaseAuth.instance.currentUser?.uid ==
                          song.userId) ...[
                    const Divider(color: Colors.white10),
                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                      child: Text(
                        "Quản lý bài hát (Tác giả)",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),

                    ListTile(
                      leading: const Icon(Icons.edit, color: Colors.white54),
                      title: const Text(
                        'Sửa bài hát',
                        style: TextStyle(color: Colors.white54),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditSongScreen(song: song),
                          ),
                        ).then(
                          (_) => context.read<SongListBloc>().add(LoadSongs()),
                        );
                      },
                    ),

                    ListTile(
                      leading: const Icon(
                        Icons.delete,
                        color: Colors.redAccent,
                      ),
                      title: const Text(
                        'Xóa bài hát',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        context.read<SongBloc>().add(DeleteSongEvent(song.id!));
                        context.read<SongListBloc>().add(LoadSongs());
                        if (currentSong?.id == song.id) {
                          player.stop();
                          playerBloc.add(StopRequested());
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
