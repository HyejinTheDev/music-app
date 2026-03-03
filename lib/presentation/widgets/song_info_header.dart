import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/song_model.dart';
import '../../logic/favorites/favorites_bloc.dart';
import '../../logic/favorites/favorites_event.dart';
import '../../logic/favorites/favorites_state.dart';

/// Widget hiển thị tên bài hát, ca sĩ + nút yêu thích
/// Tách từ song_detail_screen.dart
class SongInfoHeader extends StatelessWidget {
  final Song song;
  final bool isFavorite;

  const SongInfoHeader({Key? key, required this.song, required this.isFavorite})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: TextStyle(
                    color: theme.textTheme.titleLarge?.color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  song.artist,
                  style: const TextStyle(color: Colors.white54, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Nút thả tim — dùng FavoritesBloc
          BlocBuilder<FavoritesBloc, dynamic>(
            builder: (context, favState) {
              final isFav = favState is FavoritesState
                  ? favState.isFavorite(song)
                  : isFavorite;
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.redAccent : theme.iconTheme.color,
                  size: 30,
                ),
                onPressed: () {
                  context.read<FavoritesBloc>().add(ToggleFavorite(song));
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
