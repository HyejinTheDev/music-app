import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/song_model.dart';
import '../../logic/song_list/song_list_bloc.dart';
import '../../logic/song_list/song_list_state.dart';
import '../../logic/player/player_bloc.dart';
import '../../logic/player/player_event.dart';
import '../../logic/player/player_state.dart' as ps;
import '../../logic/favorites/favorites_bloc.dart';
import '../widgets/song_item.dart';
import '../widgets/song_options_menu.dart';

class AlbumDetailScreen extends StatelessWidget {
  final String albumTitle;
  final String albumArtist;
  final String albumCoverUrl;
  final List<String> songIds;

  const AlbumDetailScreen({
    Key? key,
    required this.albumTitle,
    required this.albumArtist,
    required this.albumCoverUrl,
    required this.songIds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<SongListBloc, SongListState>(
        builder: (context, songListState) {
          // Lọc bài hát theo songIds từ SongListBloc
          final allSongs = songListState is SongListLoaded
              ? songListState.songs
              : <Song>[];
          final albumSongs = allSongs
              .where((s) => songIds.contains(s.id.toString()))
              .toList();

          return BlocBuilder<PlayerBloc, ps.PlayerState>(
            builder: (context, playerState) {
              return CustomScrollView(
                slivers: [
                  // --- HEADER ẢNH BÌA ---
                  SliverAppBar(
                    expandedHeight: 280,
                    pinned: true,
                    backgroundColor: Colors.black,
                    iconTheme: const IconThemeData(color: Colors.white),
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        albumTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            albumCoverUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[900],
                              child: const Icon(
                                Icons.album,
                                color: Colors.white24,
                                size: 80,
                              ),
                            ),
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black87],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- THÔNG TIN ALBUM ---
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            albumArtist,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.music_note,
                            color: Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "${albumSongs.length} bài hát",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- DANH SÁCH BÀI HÁT ---
                  if (songListState is SongListLoading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.tealAccent,
                        ),
                      ),
                    )
                  else if (albumSongs.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          "Album này chưa có bài hát nào",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final song = albumSongs[index];
                        return SongItem(
                          song: song,
                          isSelected: playerState.currentSong?.id == song.id,
                          onTap: () {
                            context.read<PlayerBloc>().add(
                              PlaySongRequested(song),
                            );
                          },
                          onOptionsTap: () {
                            final favState = context
                                .read<FavoritesBloc>()
                                .state;
                            showSongOptionsMenu(
                              context: context,
                              song: song,
                              likedSongIds: favState.likedSongIds.toList(),
                              favoriteSongs: favState.favoriteSongs.toList(),
                              onStateChanged: () {},
                            );
                          },
                        );
                      }, childCount: albumSongs.length),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
