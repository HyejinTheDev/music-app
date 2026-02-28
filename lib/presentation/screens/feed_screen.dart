import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/song_model.dart';
import 'package:just_audio/just_audio.dart';

// --- MODEL BÌNH LUẬN ---
class Comment {
  final String userName;
  final String text;
  final String timeAgo;

  Comment({required this.userName, required this.text, required this.timeAgo});
}

class FeedScreen extends StatefulWidget {
  final AudioPlayer player;
  final Song? currentSong;
  final Function(Song) onPlaySong;
  final List<Song> favoriteSongs;
  final Function(Song) onToggleFavorite;

  const FeedScreen({
    Key? key,
    required this.player,
    this.currentSong,
    required this.onPlaySong,
    required this.favoriteSongs,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header của trang Feed
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Cộng đồng",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_box_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () => _showCreatePostSheet(),
                ),
              ],
            ),
          ),

          // Danh sách các bài viết — ĐỌC TỪ FIRESTORE
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Đọc trực tiếp từ Firestore — không cần orderBy để tránh lỗi index
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .snapshots(),
              builder: (context, snapshot) {
                // Đang tải
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.tealAccent),
                  );
                }

                // Lỗi
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Lỗi tải bài viết: ${snapshot.error}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }

                // Không có dữ liệu
                final docs = List<QueryDocumentSnapshot>.from(
                  snapshot.data?.docs ?? [],
                );
                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Chưa có bài viết nào\nHãy chia sẻ bài hát đầu tiên!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, height: 1.5),
                    ),
                  );
                }

                // Sắp xếp theo timestamp mới nhất (client-side)
                docs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aTime = aData['timestamp'] as Timestamp?;
                  final bTime = bData['timestamp'] as Timestamp?;
                  if (aTime == null && bTime == null) return 0;
                  if (aTime == null) return 1;
                  if (bTime == null) return -1;
                  return bTime.compareTo(aTime);
                });

                // Hiển thị danh sách bài viết
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;
                    return _buildPostCard(data, docId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // =============================================
  // BOTTOM SHEET: TẠO BÀI VIẾT MỚI (ĐĂNG LÊN FIRESTORE)
  // =============================================
  void _showCreatePostSheet() {
    final captionController = TextEditingController();
    Song? selectedSong;

    // Lấy danh sách bài hát từ Firestore (collection "songs" theo user)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
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

                    // Tiêu đề
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Tạo bài viết mới",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: selectedSong == null
                              ? null
                              : () async {
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('posts')
                                        .add({
                                          'userName':
                                              user?.displayName ??
                                              "Người dùng ẩn danh",
                                          'userAvatar':
                                              user?.photoURL ??
                                              "https://i.pravatar.cc/150?img=12",
                                          'caption':
                                              captionController.text.isNotEmpty
                                              ? captionController.text
                                              : "Đang nghe bài này 🎵",
                                          'timestamp':
                                              FieldValue.serverTimestamp(),
                                          'likes': 0,
                                          'comments': 0,
                                          'likedBy': [],
                                          'songTitle': selectedSong!.title,
                                          'songArtist': selectedSong!.artist,
                                          'songCoverUrl':
                                              selectedSong!.coverUrl,
                                          'songAudioUrl':
                                              selectedSong!.audioUrl,
                                          'songId': selectedSong!.id,
                                        });
                                    Navigator.pop(context);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Lỗi đăng bài: $e"),
                                      ),
                                    );
                                  }
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
                      style: const TextStyle(color: Colors.white),
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

                    // Tiêu đề danh sách chọn bài hát — lấy từ favoriteSongs hoặc từ Firestore
                    const Text(
                      "Chọn bài hát để chia sẻ:",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 8),

                    // Danh sách bài hát yêu thích để chọn chia sẻ
                    Expanded(
                      child: _buildSongListForSharing(
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
  /// Ưu tiên lấy từ Firestore songs của user, nếu không thì dùng favoriteSongs
  Widget _buildSongListForSharing({
    required Song? selectedSong,
    required Function(Song) onSelect,
  }) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(
        child: Text("Vui lòng đăng nhập", style: TextStyle(color: Colors.grey)),
      );
    }

    // Đọc bài hát từ Realtime Database hoặc dùng Firestore
    // Ở đây ta dùng StreamBuilder đọc từ Firestore collection "songs" theo user
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user_songs')
          .doc(user.uid)
          .collection('songs')
          .snapshots(),
      builder: (context, snapshot) {
        // Nếu chưa có collection user_songs, dùng favoriteSongs
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

        // Nếu không có trên Firestore, dùng favoriteSongs
        if (songsToShow.isEmpty) {
          songsToShow = widget.favoriteSongs;
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
                  color: isSelected ? Colors.tealAccent : Colors.white,
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
                  : const Icon(
                      Icons.radio_button_unchecked,
                      color: Colors.grey,
                    ),
              onTap: () => onSelect(song),
            );
          },
        );
      },
    );
  }

  // =============================================
  // BOTTOM SHEET: BÌNH LUẬN (ĐỌC/GHI TỪ FIRESTORE)
  // =============================================
  void _showCommentSheet(Map<String, dynamic> postData, String docId) {
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
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
                const SizedBox(height: 12),

                // Tiêu đề
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(docId)
                      .collection('comments')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final commentCount = snapshot.data?.docs.length ?? 0;
                    return Text(
                      "Bình luận ($commentCount)",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white10),

                // Danh sách bình luận từ Firestore
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .doc(docId)
                        .collection('comments')
                        .orderBy('timestamp', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.tealAccent,
                          ),
                        );
                      }

                      final comments = snapshot.data?.docs ?? [];

                      if (comments.isEmpty) {
                        return const Center(
                          child: Text(
                            "Chưa có bình luận nào\nHãy là người đầu tiên bình luận!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, height: 1.5),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final cData =
                              comments[index].data() as Map<String, dynamic>;
                          final userName = cData['userName'] ?? 'Ẩn danh';
                          final text = cData['text'] ?? '';
                          final timeAgo = cData['timeAgo'] ?? '';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.tealAccent
                                      .withOpacity(0.2),
                                  child: Text(
                                    userName.isNotEmpty
                                        ? userName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.tealAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            userName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            timeAgo,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        text,
                                        style: const TextStyle(
                                          color: Color(0xFFE0E0E0),
                                          fontSize: 14,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // Ô nhập bình luận
                const Divider(color: Colors.white10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Viết bình luận...",
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            filled: true,
                            fillColor: Colors.black26,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          if (commentController.text.trim().isNotEmpty) {
                            final user = FirebaseAuth.instance.currentUser;
                            try {
                              // Thêm bình luận vào subcollection
                              await FirebaseFirestore.instance
                                  .collection('posts')
                                  .doc(docId)
                                  .collection('comments')
                                  .add({
                                    'userName': user?.displayName ?? 'Ẩn danh',
                                    'text': commentController.text.trim(),
                                    'timeAgo': 'Vừa xong',
                                    'timestamp': FieldValue.serverTimestamp(),
                                  });

                              // Cập nhật số lượng comment trên post
                              final commentsSnapshot = await FirebaseFirestore
                                  .instance
                                  .collection('posts')
                                  .doc(docId)
                                  .collection('comments')
                                  .get();

                              await FirebaseFirestore.instance
                                  .collection('posts')
                                  .doc(docId)
                                  .update({
                                    'comments': commentsSnapshot.docs.length,
                                  });

                              commentController.clear();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Lỗi bình luận: $e")),
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.tealAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.send,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =============================================
  // VẼ TỪNG BÀI VIẾT (POST CARD) — TỪ FIRESTORE DATA
  // =============================================
  Widget _buildPostCard(Map<String, dynamic> data, String docId) {
    // Tạo Song tạm từ dữ liệu Firestore
    final sharedSong = Song(
      id: data['songId'],
      title: data['songTitle'] ?? 'Không rõ',
      artist: data['songArtist'] ?? 'Không rõ',
      lyrics: '',
      audioUrl: data['songAudioUrl'] ?? '',
    );
    // Dùng coverUrl từ Firestore nếu có, ngược lại dùng getter từ Song
    final coverUrl = data['songCoverUrl'] ?? sharedSong.coverUrl;

    final isPlayingThisSong = widget.currentSong?.id == sharedSong.id;
    final likes = data['likes'] ?? 0;
    final comments = data['comments'] ?? 0;

    // Kiểm tra user hiện tại đã like chưa
    final user = FirebaseAuth.instance.currentUser;
    final likedBy = List<String>.from(data['likedBy'] ?? []);
    final isLiked = user != null && likedBy.contains(user.uid);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: const Color(0xFF181818),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Thông tin người đăng
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                data['userAvatar'] ?? 'https://i.pravatar.cc/150?img=12',
              ),
            ),
            title: Text(
              data['userName'] ?? 'Ẩn danh',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              _formatTimestamp(data['timestamp']),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            trailing: const Icon(Icons.more_horiz, color: Colors.grey),
          ),

          // 2. Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              data['caption'] ?? '',
              style: const TextStyle(
                color: Color(0xFFE8E8E8),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),

          // 3. Bài hát được chia sẻ
          GestureDetector(
            onTap: () => widget.onPlaySong(sharedSong),
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      coverUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.music_note,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sharedSong.title,
                          style: TextStyle(
                            color: isPlayingThisSong
                                ? Colors.tealAccent
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sharedSong.artist,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder<PlayerState>(
                    stream: widget.player.playerStateStream,
                    builder: (context, snapshot) {
                      final playing = snapshot.data?.playing ?? false;
                      final isCurrent = widget.currentSong?.id == sharedSong.id;
                      return CircleAvatar(
                        backgroundColor: isCurrent
                            ? Colors.tealAccent
                            : Colors.white24,
                        radius: 20,
                        child: Icon(
                          (isCurrent && playing)
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: isCurrent ? Colors.black : Colors.white,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 4. Hàng nút Tương tác
          const Divider(color: Colors.white10, height: 1),
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
            child: Row(
              children: [
                // Nút Thích — cập nhật Firestore
                _buildInteractionButton(
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.redAccent : Colors.grey,
                  text: "$likes",
                  onTap: () => _toggleLike(docId, isLiked, likes),
                ),
                const SizedBox(width: 24),
                // Nút Bình luận
                _buildInteractionButton(
                  icon: Icons.chat_bubble_outline,
                  color: Colors.grey,
                  text: "$comments",
                  onTap: () => _showCommentSheet(data, docId),
                ),
                const Spacer(),
                // Nút Lưu vào danh sách yêu thích
                _buildInteractionButton(
                  icon: Icons.playlist_add,
                  color: Colors.grey,
                  text: "Lưu",
                  onTap: () {
                    widget.onToggleFavorite(sharedSong);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Đã lưu \"${sharedSong.title}\" vào playlist!",
                        ),
                        backgroundColor: Colors.tealAccent.withOpacity(0.8),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============================================
  // TOGGLE LIKE TRÊN FIRESTORE
  // =============================================
  Future<void> _toggleLike(
    String docId,
    bool isCurrentlyLiked,
    int currentLikes,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final postRef = FirebaseFirestore.instance.collection('posts').doc(docId);

    if (isCurrentlyLiked) {
      // Bỏ like
      await postRef.update({
        'likes': currentLikes - 1,
        'likedBy': FieldValue.arrayRemove([user.uid]),
      });
    } else {
      // Thêm like
      await postRef.update({
        'likes': currentLikes + 1,
        'likedBy': FieldValue.arrayUnion([user.uid]),
      });
    }
  }

  // =============================================
  // FORMAT TIMESTAMP
  // =============================================
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Vừa xong';
    if (timestamp is Timestamp) {
      final dateTime = timestamp.toDate();
      final now = DateTime.now();
      final diff = now.difference(dateTime);

      if (diff.inMinutes < 1) return 'Vừa xong';
      if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
      if (diff.inHours < 24) return '${diff.inHours} giờ trước';
      if (diff.inDays < 7) return '${diff.inDays} ngày trước';
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    return 'Vừa xong';
  }

  // Nút tương tác nhỏ
  Widget _buildInteractionButton({
    required IconData icon,
    required Color color,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontSize: 14)),
        ],
      ),
    );
  }
}
