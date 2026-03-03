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

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongListBloc, SongListState>(
      builder: (context, songListState) {
        final allSongs = songListState is SongListLoaded
            ? songListState.songs
            : <Song>[];

        final filteredSongs = allSongs.where((s) {
          final titleLower = s.title.toLowerCase();
          final artistLower = s.artist.toLowerCase();
          final queryLower = _searchQuery.toLowerCase();
          return titleLower.contains(queryLower) ||
              artistLower.contains(queryLower);
        }).toList();

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
                      "Tìm kiếm",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleLarge?.color,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.black),
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Bài hát, nghệ sĩ...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.black,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: filteredSongs.isEmpty
                        ? Center(
                            child: Text(
                              _searchQuery.isEmpty
                                  ? "Nhập tên bài hát hoặc ca sĩ để tìm"
                                  : "Không tìm thấy kết quả nào",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredSongs.length,
                            padding: const EdgeInsets.only(top: 10),
                            itemBuilder: (context, index) {
                              final song = filteredSongs[index];
                              return SongItem(
                                song: song,
                                isSelected: currentSong?.id == song.id,
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
                                    likedSongIds: favState.likedSongIds
                                        .toList(),
                                    favoriteSongs: favState.favoriteSongs
                                        .toList(),
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
