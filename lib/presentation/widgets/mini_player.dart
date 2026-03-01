import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/song_model.dart';
import '../screens/song_detail_screen.dart';

class MiniPlayer extends StatelessWidget {
  final Song song;
  final AudioPlayer player;
  final VoidCallback onDismissed;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final List<Song> songs;
  final Function(Song)? onSongChanged;

  const MiniPlayer({
    Key? key,
    required this.song,
    required this.player,
    required this.onDismissed,
    required this.isFavorite,
    required this.onToggleFavorite,
    this.songs = const [],
    this.onSongChanged,
  }) : super(key: key);

  void _nextSong() {
    if (songs.isEmpty) return;
    final currentIndex = songs.indexWhere((s) => s.id == song.id);
    final nextIndex = (currentIndex + 1) % songs.length;
    onSongChanged?.call(songs[nextIndex]);
  }

  void _previousSong() {
    if (songs.isEmpty) return;
    final currentIndex = songs.indexWhere((s) => s.id == song.id);
    final prevIndex = (currentIndex - 1 + songs.length) % songs.length;
    onSongChanged?.call(songs[prevIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: const Key('mini_player'),
      direction: DismissDirection.down,
      onDismissed: (_) => onDismissed(),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SongDetailScreen(
                song: song,
                player: player,
                isFavorite: isFavorite,
                onToggleFavorite: onToggleFavorite,
                songs: songs,
                onSongChanged: onSongChanged,
              ),
            ),
          );
        },
        child: Container(
          height: 70,
          margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF252525).withOpacity(0.98),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Hero(
                tag: 'current_artwork',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: Image.network(
                    song.coverUrl,
                    width: 45,
                    height: 45,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white),
                onPressed: songs.isNotEmpty ? _previousSong : null,
              ),
              // StreamBuilder tự động nghe trạng thái nhạc để đổi icon Play/Pause
              StreamBuilder<PlayerState>(
                stream: player.playerStateStream,
                builder: (context, snapshot) {
                  final playing = snapshot.data?.playing ?? false;
                  return CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        playing ? Icons.pause : Icons.play_arrow,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        if (playing)
                          player.pause();
                        else
                          player.play();
                      },
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white),
                onPressed: songs.isNotEmpty ? _nextSong : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
