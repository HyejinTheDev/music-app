import 'package:flutter/material.dart';
import '../../data/models/song_model.dart';
import '../widgets/song_item.dart';

class LibraryScreen extends StatelessWidget {
  final List<Song> favoriteSongs; // Danh sách bài hát đã lưu
  final Song? currentSong;
  final Function(Song) onPlaySong;
  final Function(Song) onOptionsTap;

  const LibraryScreen({
    Key? key,
    required this.favoriteSongs,
    this.currentSong,
    required this.onPlaySong,
    required this.onOptionsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề trang
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Text("Thư viện của tôi", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          
          // Nút tạo Playlist mới (Giao diện chờ nâng cấp)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Container(
                  width: 55, height: 55,
                  decoration: BoxDecoration(color: Colors.grey[850], borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                const Text("Tạo danh sách phát mới", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          
          const Divider(color: Colors.white10, height: 30, indent: 16, endIndent: 16),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("Bài hát yêu thích", style: TextStyle(color: Colors.grey, fontSize: 14)),
          ),
          
          const SizedBox(height: 10),
          
          // Danh sách bài hát đã lưu
          Expanded(
            child: favoriteSongs.isEmpty
                ? const Center(
                    child: Text(
                      "Thư viện đang trống\nHãy tìm và thêm bài hát bạn thích nhé!", 
                      textAlign: TextAlign.center, 
                      style: TextStyle(color: Colors.grey, height: 1.5)
                    )
                  )
                : ListView.builder(
                    itemCount: favoriteSongs.length,
                    itemBuilder: (context, index) {
                      final song = favoriteSongs[index];
                      return SongItem(
                        song: song,
                        isSelected: currentSong?.id == song.id,
                        onTap: () => onPlaySong(song),
                        onOptionsTap: () => onOptionsTap(song),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}