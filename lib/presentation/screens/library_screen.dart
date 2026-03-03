import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/favorites/favorites_bloc.dart';
import '../../logic/favorites/favorites_state.dart';
import '../../logic/player/player_bloc.dart';
import '../../logic/player/player_event.dart';
import '../../logic/player/player_state.dart' as ps;
import '../widgets/song_item.dart';
import '../widgets/song_options_menu.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, favState) {
        final favoriteSongs = favState.favoriteSongs.toList();

        return BlocBuilder<PlayerBloc, ps.PlayerState>(
          builder: (context, playerState) {
            final currentSong = playerState.currentSong;

            return SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                    child: Text(
                      "Thư viện của tôi",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleLarge?.color,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Bài hát yêu thích",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: favoriteSongs.isEmpty
                        ? const Center(
                            child: Text(
                              "Thư viện đang trống\nHãy tìm và thêm bài hát bạn thích nhé!",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, height: 1.5),
                            ),
                          )
                        : ListView.builder(
                            itemCount: favoriteSongs.length,
                            itemBuilder: (context, index) {
                              final song = favoriteSongs[index];
                              return SongItem(
                                song: song,
                                isSelected: currentSong?.id == song.id,
                                onTap: () {
                                  context.read<PlayerBloc>().add(
                                    PlaySongRequested(song),
                                  );
                                },
                                onOptionsTap: () {
                                  showSongOptionsMenu(
                                    context: context,
                                    song: song,
                                    likedSongIds: favState.likedSongIds
                                        .toList(),
                                    favoriteSongs: favoriteSongs,
                                    onStateChanged: () {},
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
