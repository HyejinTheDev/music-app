import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

// --- Imports Logic ---
import '../../data/models/song_model.dart';
import '../../logic/song_list/song_list_bloc.dart';
import '../../logic/song_list/song_list_event.dart';
import '../../logic/song_bloc/song_bloc.dart';
import '../../logic/song_bloc/song_event.dart' hide LoadSongs;
import '../screens/add_edit_song_screen.dart';

// Hàm chính gọi Menu
void showSongOptionsMenu({
  required BuildContext context,
  required Song song,
  required List<String> likedSongIds,
  required List<Song> favoriteSongs,
  required AudioPlayer player,
  required Song? currentSong,
  required VoidCallback onStateChanged,
  required VoidCallback onClearCurrentSong,
  required Function(Song, String)
  onShareToFeed, // Hàm nhận sự kiện Chia sẻ bài lên Feed
}) {
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
            final isLiked = likedSongIds.contains(songIdStr);
            final isInPlaylist = favoriteSongs.contains(song);

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
                      setModalState(() {
                        isLiked
                            ? likedSongIds.remove(songIdStr)
                            : likedSongIds.add(songIdStr);
                      });
                      onStateChanged();
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
                      Navigator.pop(context);
                      if (isInPlaylist) {
                        favoriteSongs.remove(song);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Đã xóa khỏi Thư viện")),
                        );
                      } else {
                        favoriteSongs.add(song);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Đã thêm vào Thư viện")),
                        );
                      }
                      onStateChanged();
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.share, color: Colors.white),
                    title: const Text(
                      'Chia sẻ lên Cộng đồng (Feed)',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Đóng menu 3 chấm
                      _showShareBottomSheet(
                        context,
                        song,
                        onShareToFeed,
                      ); // MỞ GIAO DIỆN CHIA SẺ MỚI
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.comment, color: Colors.white),
                    title: const Text(
                      'Xem bình luận',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showCommentsBottomSheet(context, song);
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
                      _showAuthorInfoDialog(context, song);
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
                          onClearCurrentSong();
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

// --- GIAO DIỆN CHIA SẺ KIỂU FACEBOOK MỚI CỰC XỊN ---
void _showShareBottomSheet(
  BuildContext context,
  Song song,
  Function(Song, String) onShare,
) {
  final TextEditingController captionController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Cho phép kéo cao lên sát viền trên
    backgroundColor: const Color(0xFF1E1E1E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(
            context,
          ).viewInsets.bottom, // Tự đẩy lên khi bật bàn phím
        ),
        child: Container(
          height:
              MediaQuery.of(context).size.height * 0.7, // Chiếm 70% màn hình
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. THANH HEADER (TIÊU ĐỀ + NÚT ĐĂNG)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Tạo bài viết",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      // Nếu không viết gì thì mặc định là "Đang nghe bài hát này!"
                      String caption = captionController.text.trim();
                      if (caption.isEmpty)
                        caption = "Đang nghe bài hát này! 🎶";

                      onShare(song, caption);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Đã đăng bài lên Feed!"),
                          backgroundColor: Colors.teal,
                        ),
                      );
                    },
                    child: const Text(
                      "Đăng",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white10),

              // 2. THÔNG TIN NGƯỜI DÙNG (Giả lập Avatar)
              Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: NetworkImage(
                      "https://i.pravatar.cc/150?img=12",
                    ), // Avatar mẫu
                    radius: 22,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Bạn",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.public, color: Colors.grey, size: 14),
                            SizedBox(width: 4),
                            Text(
                              "Công khai",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. KHUNG NHẬP CẢM NGHĨ
              Expanded(
                child: TextField(
                  controller: captionController,
                  maxLines: null, // Viết dài thoải mái
                  autofocus: true, // Tự động bật bàn phím
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: const InputDecoration(
                    hintText: "Bạn đang nghĩ gì về bài hát này?",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
                    border: InputBorder.none, // Xóa viền đi cho đẹp
                  ),
                ),
              ),

              // 4. KHUNG BÀI HÁT ĐÍNH KÈM Ở DƯỚI CÙNG
              Container(
                margin: const EdgeInsets.only(bottom: 10, top: 10),
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
                        song.coverUrl,
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
                            song.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            song.artist,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
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

// --- CÁC HÀM PHỤ KHÁC ---
void _showCommentsBottomSheet(BuildContext context, Song song) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1E1E1E),
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Bình luận",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: 3,
              itemBuilder: (context, index) => ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  "User ${index + 1}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: const Text(
                  "Bài này nghe hay quá ad ơi! Đỉnh của chóp 🔥",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 8,
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Thêm bình luận...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.black,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.tealAccent),
                  onPressed: () {},
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}

void _showAuthorInfoDialog(BuildContext context, Song song) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF252525),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text(
        "Thông tin Bài hát",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ClipOval(
              child: Image.network(
                song.coverUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Tên bài hát: ${song.title}",
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            "Trình bày / Sáng tác: ${song.artist}",
            style: const TextStyle(
              color: Colors.tealAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Năm phát hành: 2024\nBản quyền thuộc về cộng đồng chia sẻ âm nhạc.",
            style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Đóng", style: TextStyle(color: Colors.tealAccent)),
        ),
      ],
    ),
  );
}
