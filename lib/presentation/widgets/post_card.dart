import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/song_model.dart';
import '../../logic/feed/feed_bloc.dart';
import '../../logic/feed/feed_event.dart';
import 'post_options_menu.dart';

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

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: theme.cardColor,
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
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              _formatTimestamp(data['timestamp']),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            trailing: GestureDetector(
              onTap: () => showPostOptionsMenu(context, data, docId),
              child: const Icon(Icons.more_horiz, color: Colors.grey),
            ),
          ),

          // 2. Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              data['caption'] ?? '',
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9),
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
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
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
                                : theme.textTheme.bodyLarge?.color,
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
          Divider(color: theme.dividerColor, height: 1),
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
                        postOwnerUserId: data['userId'] ?? '',
                        songTitle: data['songTitle'] ?? '',
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
}
