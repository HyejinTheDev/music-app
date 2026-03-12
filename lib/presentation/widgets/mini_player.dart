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
    final theme = Theme.of(context);

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
          margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nội dung chính
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    // Ảnh bìa
                    Hero(
                      tag: 'current_artwork',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          song.coverUrl,
                          width: 46,
                          height: 46,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.music_note,
                              color: Colors.white54,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Thông tin bài hát
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
                              color: theme.textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Nút previous
                    IconButton(
                      icon: Icon(
                        Icons.skip_previous,
                        color: theme.iconTheme.color,
                        size: 22,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: songs.isNotEmpty
                          ? () => playerBloc.add(PreviousSongRequested())
                          : null,
                    ),
                    // Nút Play/Pause
                    StreamBuilder<PlayerState>(
                      stream: player.playerStateStream,
                      builder: (context, snapshot) {
                        final playing = snapshot.data?.playing ?? false;
                        return Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: Colors.tealAccent,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              playing ? Icons.pause : Icons.play_arrow,
                              color: Colors.black,
                              size: 22,
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
                    // Nút next
                    IconButton(
                      icon: Icon(
                        Icons.skip_next,
                        color: theme.iconTheme.color,
                        size: 22,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: songs.isNotEmpty
                          ? () => playerBloc.add(NextSongRequested())
                          : null,
                    ),
                  ],
                ),
              ),
              // Thanh progress nhỏ
              StreamBuilder<Duration?>(
                stream: player.durationStream,
                builder: (context, durationSnap) {
                  final total = durationSnap.data ?? Duration.zero;
                  return StreamBuilder<Duration>(
                    stream: player.positionStream,
                    builder: (context, posSnap) {
                      final pos = posSnap.data ?? Duration.zero;
                      final progress = total.inMilliseconds > 0
                          ? pos.inMilliseconds / total.inMilliseconds
                          : 0.0;
                      return ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        ),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          minHeight: 2.5,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.tealAccent,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
