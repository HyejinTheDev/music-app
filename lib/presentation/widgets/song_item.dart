import 'package:flutter/material.dart';
import '../../data/models/song_model.dart';

class SongItem extends StatelessWidget {
  final Song song;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onOptionsTap;

  const SongItem({
    Key? key,
    required this.song,
    required this.isSelected,
    required this.onTap,
    required this.onOptionsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(song.coverUrl, width: 50, height: 50, fit: BoxFit.cover),
      ),
      title: Text(
        song.title,
        style: TextStyle(
          color: isSelected ? Colors.tealAccent : Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(song.artist, style: const TextStyle(color: Colors.grey)),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.grey),
        onPressed: onOptionsTap, // Gọi hàm mở menu 3 chấm
      ),
      onTap: onTap, // Gọi hàm phát nhạc
    );
  }
}