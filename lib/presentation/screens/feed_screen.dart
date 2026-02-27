import 'package:flutter/material.dart';
import '../../data/models/song_model.dart';
import 'package:just_audio/just_audio.dart';

// --- MODEL BÌNH LUẬN ---
class Comment {
  final String userName;
  final String text;
  final String timeAgo;

  Comment({required this.userName, required this.text, required this.timeAgo});
}

// --- MODEL BÀI VIẾT (POST) ---
class Post {
  final String userName;
  final String userAvatar;
  final String timeAgo;
  final String caption;
  final Song sharedSong;
  int likes;
  int comments;
  bool isLiked;
  final List<Comment> commentList; // Danh sách bình luận

  Post({
    required this.userName,
    required this.userAvatar,
    required this.timeAgo,
    required this.caption,
    required this.sharedSong,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
    List<Comment>? commentList,
  }) : commentList = commentList ?? [];
}

class FeedScreen extends StatefulWidget {
  final List<Post> posts;
  final AudioPlayer player;
  final Song? currentSong;
  final Function(Song) onPlaySong;
  final List<Song>
  allSongs; // Danh sách tất cả bài hát (để chọn khi tạo bài viết)
  final Function(Song) onSaveToPlaylist; // Callback lưu bài hát vào playlist
  final Function(Post) onAddPost; // Callback thêm bài viết mới

  const FeedScreen({
    Key? key,
    required this.posts,
    required this.player,
    this.currentSong,
    required this.onPlaySong,
    required this.allSongs,
    required this.onSaveToPlaylist,
    required this.onAddPost,
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
                ), // Nút để đăng bài
              ],
            ),
          ),

          // Danh sách các bài viết
          Expanded(
            child: widget.posts.isEmpty
                ? const Center(
                    child: Text(
                      "Chưa có bài viết nào",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.posts.length,
                    itemBuilder: (context, index) {
                      return _buildPostCard(widget.posts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // =============================================
  // BOTTOM SHEET: TẠO BÀI VIẾT MỚI
  // =============================================
  void _showCreatePostSheet() {
    final captionController = TextEditingController();
    Song? selectedSong;

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
                              : () {
                                  final newPost = Post(
                                    userName: "Bạn",
                                    userAvatar:
                                        "https://i.pravatar.cc/150?img=12",
                                    timeAgo: "Vừa xong",
                                    caption: captionController.text.isNotEmpty
                                        ? captionController.text
                                        : "Đang nghe bài này 🎵",
                                    sharedSong: selectedSong!,
                                  );
                                  widget.onAddPost(newPost);
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

                    // Tiêu đề danh sách chọn bài hát
                    const Text(
                      "Chọn bài hát để chia sẻ:",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 8),

                    // Danh sách bài hát
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.allSongs.length,
                        itemBuilder: (context, index) {
                          final song = widget.allSongs[index];
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
                                    : Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              song.artist,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.tealAccent,
                                  )
                                : const Icon(
                                    Icons.radio_button_unchecked,
                                    color: Colors.grey,
                                  ),
                            onTap: () =>
                                setSheetState(() => selectedSong = song),
                          );
                        },
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

  // =============================================
  // BOTTOM SHEET: BÌNH LUẬN
  // =============================================
  void _showCommentSheet(Post post) {
    final commentController = TextEditingController();

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
                    Text(
                      "Bình luận (${post.commentList.length})",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white10),

                    // Danh sách bình luận
                    Expanded(
                      child: post.commentList.isEmpty
                          ? const Center(
                              child: Text(
                                "Chưa có bình luận nào\nHãy là người đầu tiên bình luận!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  height: 1.5,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: post.commentList.length,
                              itemBuilder: (context, index) {
                                final comment = post.commentList[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.tealAccent
                                            .withOpacity(0.2),
                                        child: Text(
                                          comment.userName[0].toUpperCase(),
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
                                                  comment.userName,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  comment.timeAgo,
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              comment.text,
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
                            onTap: () {
                              if (commentController.text.trim().isNotEmpty) {
                                final newComment = Comment(
                                  userName: "Bạn",
                                  text: commentController.text.trim(),
                                  timeAgo: "Vừa xong",
                                );
                                setSheetState(() {
                                  post.commentList.add(newComment);
                                  post.comments = post.commentList.length;
                                });
                                // Cập nhật UI bên ngoài
                                setState(() {});
                                commentController.clear();
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
      },
    );
  }

  // =============================================
  // VẼ TỪNG BÀI VIẾT (POST CARD)
  // =============================================
  Widget _buildPostCard(Post post) {
    final isPlayingThisSong = widget.currentSong?.id == post.sharedSong.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: const Color(0xFF181818),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Thông tin người đăng (Avatar, Tên, Thời gian)
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(post.userAvatar),
            ),
            title: Text(
              post.userName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              post.timeAgo,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            trailing: const Icon(Icons.more_horiz, color: Colors.grey),
          ),

          // 2. Dòng trạng thái (Caption)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              post.caption,
              style: const TextStyle(
                color: Color(0xFFE8E8E8),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),

          // 3. Khung chứa Bài hát được chia sẻ
          GestureDetector(
            onTap: () => widget.onPlaySong(post.sharedSong),
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
                      post.sharedSong.coverUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.sharedSong.title,
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
                          post.sharedSong.artist,
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
                      final isCurrent =
                          widget.currentSong?.id == post.sharedSong.id;
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

          // 4. Hàng nút Tương tác (Tim, Bình luận, Lưu vào Playlist)
          const Divider(color: Colors.white10, height: 1),
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
            child: Row(
              children: [
                // Nút Thích
                _buildInteractionButton(
                  icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: post.isLiked ? Colors.redAccent : Colors.grey,
                  text: "${post.likes}",
                  onTap: () {
                    setState(() {
                      post.isLiked = !post.isLiked;
                      post.isLiked ? post.likes++ : post.likes--;
                    });
                  },
                ),
                const SizedBox(width: 24),
                // Nút Bình luận — mở bottom sheet
                _buildInteractionButton(
                  icon: Icons.chat_bubble_outline,
                  color: Colors.grey,
                  text: "${post.comments}",
                  onTap: () => _showCommentSheet(post),
                ),
                const Spacer(),
                // Nút Lưu vào Playlist (thay thế nút Chia sẻ)
                _buildInteractionButton(
                  icon: Icons.playlist_add,
                  color: Colors.grey,
                  text: "Lưu",
                  onTap: () {
                    widget.onSaveToPlaylist(post.sharedSong);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Đã lưu \"${post.sharedSong.title}\" vào playlist!",
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
