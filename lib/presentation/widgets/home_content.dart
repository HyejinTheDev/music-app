import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/song_model.dart';
import '../../logic/song_list/song_list_bloc.dart';
import '../../logic/song_list/song_list_event.dart';
import '../../logic/player/player_bloc.dart';
import '../../logic/player/player_event.dart';
import '../../logic/favorites/favorites_bloc.dart';
import '../../l10n/app_localizations.dart';
import 'song_item.dart';
import 'song_options_menu.dart';
import 'promo_banner.dart';
import 'artist_banner.dart';
import 'album_banner.dart';

/// Nội dung trang chủ (tab Home)
/// Tách từ home_screen.dart
class HomeContent extends StatelessWidget {
  final List<Song> songs;
  final Song? currentSong;

  const HomeContent({Key? key, required this.songs, this.currentSong})
    : super(key: key);

  void _playMusic(BuildContext context, Song song) {
    context.read<PlayerBloc>().add(PlaySongRequested(song));
  }

  void _handleShowOptions(BuildContext context, Song song) {
    final favState = context.read<FavoritesBloc>().state;
    showSongOptionsMenu(
      context: context,
      song: song,
      likedSongIds: favState.likedSongIds.toList(),
      favoriteSongs: favState.favoriteSongs.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF2C3E50), Colors.black]
              : [Colors.teal.shade100, theme.scaffoldBackgroundColor],
          stops: const [0.0, 0.3],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(context, loc),
              _buildSectionTitle(context, loc.translate('featured_artists')),
              ArtistBanner(
                songs: songs,
                onTap: (song) => _playMusic(context, song),
              ),
              const PromoBanner(),
              _buildSectionTitle(context, loc.translate('suggestions')),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: min(10, songs.length),
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return SongItem(
                    song: song,
                    isSelected: currentSong?.id == song.id,
                    onTap: () => _playMusic(context, song),
                    onOptionsTap: () => _handleShowOptions(context, song),
                  );
                },
              ),
              _buildSectionTitle(context, loc.translate('latest_albums')),
              const AlbumBanner(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppLocalizations loc) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            loc.translate('app_title'),
            style: TextStyle(
              color: theme.textTheme.titleLarge?.color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: theme.iconTheme.color),
            onPressed: () => context.read<SongListBloc>().add(LoadSongs()),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        title,
        style: TextStyle(
          color: theme.textTheme.titleLarge?.color,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
