import 'package:flutter/material.dart';
import '../../data/models/song_model.dart';

/// Banner danh sách nghệ sĩ nổi bật (scroll ngang)
/// Tách từ home_screen._buildArtistBanner
class ArtistBanner extends StatelessWidget {
  final List<Song> songs;
  final Function(Song) onTap;

  const ArtistBanner({Key? key, required this.songs, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: songs.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => onTap(songs[index]),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 80,
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(songs[index].coverUrl),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  songs[index].artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
