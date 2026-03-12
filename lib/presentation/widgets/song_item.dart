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
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.tealAccent.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Hero(
          tag: 'song_cover_${song.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              song.coverUrl,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.music_note,
                  color: Colors.white38,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isSelected
                ? Colors.tealAccent
                : theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              song.artist,
              style: TextStyle(
                color: isSelected
                    ? Colors.tealAccent.withValues(alpha: 0.6)
                    : Colors.grey,
                fontSize: 13,
              ),
            ),
            if (song.uploaderName != null && song.uploaderName!.isNotEmpty)
              Text(
                "Đăng bởi: ${song.uploaderName}",
                style: TextStyle(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white30
                      : Colors.grey.shade400,
                  fontSize: 11,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
          onPressed: onOptionsTap,
        ),
        onTap: onTap,
      ),
    );
  }
}
