import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/song_model.dart';
import '../../logic/player/player_bloc.dart';
import '../../logic/player/player_event.dart';
import '../../logic/favorites/favorites_bloc.dart';
import '../widgets/song_item.dart';
import '../widgets/song_options_menu.dart';

/// Màn hình hiển thị tất cả bài hát
class AllSongsScreen extends StatelessWidget {
  final List<Song> songs;
  final Song? currentSong;

  const AllSongsScreen({Key? key, required this.songs, this.currentSong})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Tất cả bài hát (${songs.length})",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        iconTheme: IconThemeData(color: theme.iconTheme.color),
      ),
      body: ListView.builder(
        itemCount: songs.length,
        padding: const EdgeInsets.only(bottom: 100),
        itemBuilder: (context, index) {
          final song = songs[index];
          return SongItem(
            song: song,
            isSelected: currentSong?.id == song.id,
            onTap: () {
              context.read<PlayerBloc>().add(PlaySongRequested(song));
            },
            onOptionsTap: () {
              final favState = context.read<FavoritesBloc>().state;
              showSongOptionsMenu(
                context: context,
                song: song,
                likedSongIds: favState.likedSongIds.toList(),
                favoriteSongs: favState.favoriteSongs.toList(),
              );
            },
          );
        },
      ),
    );
  }
}
