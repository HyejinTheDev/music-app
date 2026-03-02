import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/song_model.dart';
import '../../logic/feed/feed_bloc.dart';
import '../../logic/feed/feed_event.dart';
import '../../data/repositories/post_repository.dart';

/// Widget hiển thị một bài viết trên Feed
/// Tách từ feed_screen._buildPostCard
class PostCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final Song? currentSong;
  final AudioPlayer player;
  final Function(Song) onPlaySong;
  final Function(Song) onToggleFavorite;
  final VoidCallback? onCommentTap;

  const PostCard({
    Key? key,
    required this.data,
    required this.docId,
    this.currentSong,
    required this.player,
    required this.onPlaySong,
    required this.onToggleFavorite,
    this.onCommentTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tạo Song tạm từ dữ liệu Firestore
    final sharedSong = Song(
      id: data['songId'],
      title: data['songTitle'] ?? 'Không rõ',
      artist: data['songArtist'] ?? 'Không rõ',
      lyrics: '',
      audioUrl: data['songAudioUrl'] ?? '',
    );
    final coverUrl = data['songCoverUrl'] ?? sharedSong.coverUrl;
    final isPlayingThisSong = currentSong?.id == sharedSong.id;
    final likes = data['likes'] ?? 0;
    final comments = data['comments'] ?? 0;

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
            trailing: GestureDetector(
              onTap: () => _showPostOptionsMenu(context, data, docId),
              child: const Icon(Icons.more_horiz, color: Colors.grey),
            ),
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
            onTap: () => onPlaySong(sharedSong),
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
                    stream: player.playerStateStream,
                    builder: (context, snapshot) {
                      final playing = snapshot.data?.playing ?? false;
                      final isCurrent = currentSong?.id == sharedSong.id;
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
                _buildInteractionButton(
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.redAccent : Colors.grey,
                  text: "$likes",
                  onTap: () {
                    context.read<FeedBloc>().add(
                      ToggleLike(
                        docId: docId,
                        isCurrentlyLiked: isLiked,
                        currentLikes: likes,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 24),
                _buildInteractionButton(
                  icon: Icons.chat_bubble_outline,
                  color: Colors.grey,
                  text: "$comments",
                  onTap: onCommentTap ?? () {},
                ),
                const Spacer(),
                _buildInteractionButton(
                  icon: Icons.playlist_add,
                  color: Colors.grey,
                  text: "Lưu",
                  onTap: () {
                    onToggleFavorite(sharedSong);
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

  // =============================================
  // MENU 3 CHẤM — CHỈ NGƯỜI ĐĂNG MỚI SỬA/XÓA
  // =============================================
  void _showPostOptionsMenu(
    BuildContext context,
    Map<String, dynamic> data,
    String docId,
  ) {
    final user = FirebaseAuth.instance.currentUser;
    final postUserId = data['userId'];
    final isOwner =
        user != null && postUserId != null && user.uid == postUserId;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              if (isOwner) ...[
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.tealAccent),
                  title: const Text(
                    "Chỉnh sửa bài viết",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showEditPostSheet(context, data, docId);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    "Xóa bài viết",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _confirmDeletePost(context, docId);
                  },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(
                    Icons.flag_outlined,
                    color: Colors.orangeAccent,
                  ),
                  title: const Text(
                    "Báo cáo bài viết",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Đã gửi báo cáo. Cảm ơn bạn!"),
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeletePost(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            "Xóa bài viết?",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Bạn có chắc muốn xóa bài viết này? Hành động này không thể hoàn tác.",
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<FeedBloc>().add(DeletePost(docId));
              },
              child: const Text(
                "Xóa",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditPostSheet(
    BuildContext context,
    Map<String, dynamic> data,
    String docId,
  ) {
    final captionController = TextEditingController(
      text: data['caption'] ?? '',
    );

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
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Chỉnh sửa bài viết",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<FeedBloc>().add(
                        EditPost(
                          docId: docId,
                          newCaption: captionController.text.trim(),
                        ),
                      );
                      Navigator.pop(sheetContext);
                    },
                    child: const Text(
                      "Lưu",
                      style: TextStyle(
                        color: Colors.tealAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        data['songCoverUrl'] ?? '',
                        width: 45,
                        height: 45,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 45,
                          height: 45,
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white54,
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
                            data['songTitle'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            data['songArtist'] ?? '',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: captionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Nội dung bài viết...",
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
