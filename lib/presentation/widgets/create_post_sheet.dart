import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/song_model.dart';
import '../../logic/feed/feed_bloc.dart';
import '../../logic/feed/feed_event.dart';
import '../../data/repositories/post_repository.dart';

/// Bottom sheet tạo bài viết mới trên Feed
/// Tách từ feed_screen._showCreatePostSheet
void showCreatePostSheet(
  BuildContext context, {
  required List<Song> favoriteSongs,
}) {
  final captionController = TextEditingController();
  Song? selectedSong;
  final feedBloc = context.read<FeedBloc>();
  final postRepository = context.read<PostRepository>();

  final theme = Theme.of(context);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: theme.cardColor,
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
              top: 16,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thanh kéo
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tiêu đề + nút Đăng bài
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tạo bài viết mới",
                        style: TextStyle(
                          color: theme.textTheme.titleLarge?.color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: selectedSong == null
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
                        child: Text(
                          "Đăng bài",
                          style: TextStyle(
                            color: selectedSong != null
                                ? Colors.tealAccent
                                : Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Ô nhập caption
                  TextField(
                    controller: captionController,
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Bạn đang nghĩ gì?...",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bài hát đã chọn
                  if (selectedSong != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.tealAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.tealAccent.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              selectedSong!.coverUrl,
                              width: 45,
                              height: 45,
                              fit: BoxFit.cover,
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
                                    fontWeight: FontWeight.bold,
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
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () =>
                                setSheetState(() => selectedSong = null),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Tiêu đề danh sách chọn bài hát
                  const Text(
                    "Chọn bài hát để chia sẻ:",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 8),

                  // Danh sách bài hát
                  Expanded(
                    child: _buildSongListForSharing(
                      favoriteSongs: favoriteSongs,
                      postRepository: postRepository,
                      selectedSong: selectedSong,
                      onSelect: (song) =>
                          setSheetState(() => selectedSong = song),
                    ),
                  ),
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
  required PostRepository postRepository,
  required Song? selectedSong,
  required Function(Song) onSelect,
}) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return const Center(
      child: Text("Vui lòng đăng nhập", style: TextStyle(color: Colors.grey)),
    );
  }

  return StreamBuilder<QuerySnapshot>(
    stream: postRepository.getUserSongsStream(user.uid),
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

      if (songsToShow.isEmpty) {
        songsToShow = favoriteSongs;
      }

      if (songsToShow.isEmpty) {
        return const Center(
          child: Text(
            "Chưa có bài hát nào.\nHãy thêm bài hát trong trang Profile!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.5),
          ),
        );
      }

      return ListView.builder(
        itemCount: songsToShow.length,
        itemBuilder: (context, index) {
          final song = songsToShow[index];
          final isSelected = selectedSong?.id == song.id;
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                song.coverUrl,
                width: 45,
                height: 45,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              song.title,
              style: TextStyle(
                color: isSelected
                    ? Colors.tealAccent
                    : Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              song.artist,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Colors.tealAccent)
                : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
            onTap: () => onSelect(song),
          );
        },
      );
    },
  );
}
