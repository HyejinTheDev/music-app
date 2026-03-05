import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/song_model.dart';
import '../../logic/player/player_bloc.dart';
import '../../logic/player/player_event.dart';
import '../screens/song_detail_screen.dart';

/// MiniPlayer thu gọn — dùng PlayerBloc thay vì callback
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

  @override
  Widget build(BuildContext context) {
    final playerBloc = context.read<PlayerBloc>();

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
            color: Theme.of(context).cardColor.withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
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
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(35),
                      ),
                      child: const Icon(
                        Icons.music_note,
                        color: Colors.white54,
                        size: 24,
                      ),
                    ),
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
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
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
              // Nút previous — dùng PlayerBloc
              IconButton(
                icon: Icon(
                  Icons.skip_previous,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: songs.isNotEmpty
                    ? () => playerBloc.add(PreviousSongRequested())
                    : null,
              ),
              // Nút Play/Pause — stream trạng thái
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
                        if (playing) {
                          playerBloc.add(PauseRequested());
                        } else {
                          playerBloc.add(ResumeRequested());
                        }
                      },
                    ),
                  );
                },
              ),
              // Nút next — dùng PlayerBloc
              IconButton(
                icon: Icon(
                  Icons.skip_next,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: songs.isNotEmpty
                    ? () => playerBloc.add(NextSongRequested())
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
