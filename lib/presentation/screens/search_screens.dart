import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/models/song_model.dart';
import '../widgets/song_item.dart';

class SearchScreen extends StatefulWidget {
  final List<Song> songs;
  final Song? currentSong;
  final AudioPlayer? player;
  final Function(Song) onPlaySong;
  final Function(Song) onOptionsTap;

  const SearchScreen({
    Key? key,
    required this.songs,
    this.currentSong,
    this.player,
    required this.onPlaySong,
    required this.onOptionsTap,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Hai biến này giờ đã được dọn sang đây, tự do tự tại không phiền đến HomeScreen
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Logic lọc bài hát cực mượt (tìm theo Tên bài hoặc Ca sĩ)
    final filteredSongs = widget.songs.where((s) {
      final titleLower = s.title.toLowerCase();
      final artistLower = s.artist.toLowerCase();
      final queryLower = _searchQuery.toLowerCase();
      return titleLower.contains(queryLower) ||
          artistLower.contains(queryLower);
    }).toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Tiêu đề
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Text(
              "Tìm kiếm",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 2. Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black),
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Bài hát, nghệ sĩ...',
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                // Nút X để xóa nhanh chữ vừa gõ
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.black),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 3. Danh sách kết quả (Dùng lại SongItem)
          Expanded(
            child: filteredSongs.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? "Nhập tên bài hát hoặc ca sĩ để tìm"
                          : "Không tìm thấy kết quả nào",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredSongs.length,
                    padding: const EdgeInsets.only(top: 10),
                    itemBuilder: (context, index) {
                      final song = filteredSongs[index];
                      return SongItem(
                        song: song,
                        isSelected: widget.currentSong?.id == song.id,
                        // Quan trọng: Truyền tín hiệu về cho HomeScreen khi bấm
                        onTap: () => widget.onPlaySong(song),
                        onOptionsTap: () => widget.onOptionsTap(song),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
