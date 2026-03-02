import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/favorites/favorites_bloc.dart';
import '../../logic/favorites/favorites_state.dart';
import '../../logic/player/player_bloc.dart';
import '../../logic/player/player_event.dart';
import '../../logic/player/player_state.dart' as ps;
import '../widgets/song_item.dart';
import '../widgets/song_options_menu.dart';

class FavoritesDetailScreen extends StatelessWidget {
  const FavoritesDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Danh sách yêu thích",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, favState) {
          final songs = favState.favoriteSongs;

          if (songs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, color: Colors.white24, size: 80),
                  SizedBox(height: 16),
                  Text(
                    "Chưa có bài hát yêu thích",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Nhấn ❤️ để thêm bài hát vào đây!",
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
