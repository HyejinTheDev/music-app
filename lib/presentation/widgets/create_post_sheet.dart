import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/song_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../logic/feed/feed_bloc.dart';
import '../../logic/feed/feed_event.dart';
import '../../data/repositories/post_repository.dart';

/// Bottom sheet tạo bài viết mới trên Feed
void showCreatePostSheet(
  BuildContext context, {
  required List<Song> favoriteSongs,
  List<Song> allSongs = const [],
}) {
  final captionController = TextEditingController();
  Song? selectedSong;
  final feedBloc = context.read<FeedBloc>();
  final postRepository = context.read<PostRepository>();
  final currentUid = context.read<AuthRepository>().currentUserId;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1A1A1A),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 12,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thanh kéo
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tạo bài viết mới",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: selectedSong == null
                            ? null
                            : () {
                                feedBloc.add(
                                  CreatePost(
                                    caption: captionController.text,
                                    song: selectedSong!,
                                  ),
                                );
                                Navigator.pop(context);
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selectedSong != null
                                ? Colors.tealAccent
                                : Colors.grey[800],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Đăng bài",
                            style: TextStyle(
                              color: selectedSong != null
                                  ? Colors.black
                                  : Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Ô nhập caption
                  TextField(
                    controller: captionController,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Bạn đang nghĩ gì?...",
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.tealAccent),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Bài hát đã chọn
                  if (selectedSong != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.tealAccent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.tealAccent.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              selectedSong!.coverUrl,
                              width: 42,
                              height: 42,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 42,
                                height: 42,
                                color: Colors.grey[800],
                                child: const Icon(
                                  Icons.music_note,
                                  color: Colors.white38,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedSong!.title,
                                  style: const TextStyle(
                                    color: Colors.tealAccent,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  selectedSong!.artist,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.grey,
                              size: 18,
                            ),
                            onPressed: () =>
                                setSheetState(() => selectedSong = null),
                          ),
                        ],
                      ),
                    ),

                  // Label danh sách
                  Row(
                    children: [
                      const Icon(
                        Icons.library_music,
                        color: Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Chọn bài hát để chia sẻ",
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Danh sách bài hát
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: _buildSongListForSharing(
                        favoriteSongs: favoriteSongs,
                        allSongs: allSongs,
                        postRepository: postRepository,
                        selectedSong: selectedSong,
                        currentUid: currentUid,
                        onSelect: (song) =>
                            setSheetState(() => selectedSong = song),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

/// Lấy danh sách bài hát để chọn chia sẻ
Widget _buildSongListForSharing({
  required List<Song> favoriteSongs,
  List<Song> allSongs = const [],
  required PostRepository postRepository,
  required Song? selectedSong,
  required String? currentUid,
  required Function(Song) onSelect,
}) {
  if (currentUid == null) {
    return const Center(
      child: Text("Vui lòng đăng nhập", style: TextStyle(color: Colors.grey)),
    );
  }

  return StreamBuilder<QuerySnapshot>(
    stream: postRepository.getUserSongsStream(currentUid),
    builder: (context, snapshot) {
      List<Song> songsToShow = [];

      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
        songsToShow = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Song(
            id: data['id'],
            title: data['title'] ?? '',
            artist: data['artist'] ?? '',
            lyrics: data['lyrics'] ?? '',
            audioUrl: data['audio_url'] ?? data['audioUrl'] ?? '',
          );
        }).toList();
      }

      if (songsToShow.isEmpty) songsToShow = favoriteSongs;
      if (songsToShow.isEmpty) songsToShow = allSongs;

      if (songsToShow.isEmpty) {
        return const Center(
          child: Text(
            "Chưa có bài hát nào.\nHãy thêm bài hát trong trang Profile!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.5),
          ),
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListView.builder(
          itemCount: songsToShow.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final song = songsToShow[index];
            final isSelected = selectedSong?.id == song.id;
            return Container(
              color: isSelected
                  ? Colors.tealAccent.withValues(alpha: 0.06)
                  : Colors.transparent,
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    song.coverUrl,
                    width: 42,
                    height: 42,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 42,
                      height: 42,
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.music_note,
                        color: Colors.white38,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  song.title,
                  style: TextStyle(
                    color: isSelected ? Colors.tealAccent : Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  song.artist,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                trailing: Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.tealAccent : Colors.grey[700],
                  size: 20,
                ),
                onTap: () => onSelect(song),
              ),
            );
          },
        ),
      );
    },
  );
}
