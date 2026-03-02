import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/logic/history/history_event.dart';
import '../../data/models/song_model.dart';
import '../../logic/history/history_bloc.dart';
import '../../logic/history/history_state.dart';
import '../../logic/player/player_bloc.dart';
import '../../logic/player/player_event.dart';
import '../../logic/player/player_state.dart' as ps;
import '../../logic/favorites/favorites_bloc.dart';
import '../widgets/song_item.dart';
import '../widgets/song_options_menu.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Lịch sử đã nghe",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.grey),
            tooltip: "Xóa lịch sử",
            onPressed: () {
              context.read<HistoryBloc>().add(ClearHistory());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Đã xóa lịch sử nghe nhạc"),
                  backgroundColor: Colors.teal,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, historyState) {
          final songs = historyState.songs;

          if (songs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, color: Colors.white24, size: 80),
                  SizedBox(height: 16),
                  Text(
                    "Chưa có lịch sử nghe nhạc",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Hãy phát một bài hát để bắt đầu!",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return BlocBuilder<PlayerBloc, ps.PlayerState>(
            builder: (context, playerState) {
              return ListView.builder(
                itemCount: songs.length,
                padding: const EdgeInsets.only(top: 8),
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return SongItem(
                    song: song,
                    isSelected: playerState.currentSong?.id == song.id,
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
                        onStateChanged: () {},
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
