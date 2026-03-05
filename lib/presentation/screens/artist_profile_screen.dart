import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/artist_profile.dart';
import '../../data/models/song_model.dart';
import '../../logic/artist_profile/artist_profile_bloc.dart';
import '../../logic/artist_profile/artist_profile_event.dart';
import '../../logic/artist_profile/artist_profile_state.dart';
import '../../logic/player/player_bloc.dart';
import '../../logic/player/player_event.dart';
import '../../logic/favorites/favorites_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/song_item.dart';
import '../widgets/song_options_menu.dart';

/// Màn hình thông tin nghệ sĩ — hiển thị avatar, tên, và danh sách bài hát
class ArtistProfileScreen extends StatelessWidget {
  final ArtistProfile artist;
  final List<Song> allSongs;

  const ArtistProfileScreen({
    Key? key,
    required this.artist,
    required this.allSongs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ArtistProfileBloc()
            ..add(LoadArtistProfile(artist: artist, allSongs: allSongs)),
      child: const _ArtistProfileView(),
    );
  }
}

class _ArtistProfileView extends StatelessWidget {
  const _ArtistProfileView();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocBuilder<ArtistProfileBloc, ArtistProfileState>(
        builder: (context, state) {
          if (state is ArtistProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.tealAccent),
            );
          }

          if (state is ArtistProfileError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
            );
          }

          if (state is ArtistProfileLoaded) {
            return _buildContent(context, state, loc, theme);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ArtistProfileLoaded state,
    AppLocalizations loc,
    ThemeData theme,
  ) {
    final artist = state.artist;
    final songs = state.artistSongs;
    final isDark = theme.brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        // --- Header với hiệu ứng gradient ---
        SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xFF1A3A4A), theme.scaffoldBackgroundColor]
                    : [Colors.teal.shade200, theme.scaffoldBackgroundColor],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Nút back
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: theme.iconTheme.color,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Avatar nghệ sĩ
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.tealAccent.withValues(alpha: 0.6),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.tealAccent.withValues(alpha: 0.25),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                      image: artist.avatarUrl != null
                          ? DecorationImage(
                              image: NetworkImage(artist.avatarUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: artist.avatarUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white24,
                          )
                        : null,
                  ),

                  const SizedBox(height: 16),

                  // Tên nghệ sĩ
                  Text(
                    artist.displayName,
                    style: TextStyle(
                      color: theme.textTheme.titleLarge?.color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Số bài hát
                  Text(
                    '${songs.length} ${loc.translate('song_count')}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),

        // --- Tiêu đề danh sách bài hát ---
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              loc.translate('uploaded_songs'),
              style: TextStyle(
                color: theme.textTheme.titleLarge?.color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // --- Danh sách bài hát ---
        songs.isEmpty
            ? SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.music_off,
                          size: 60,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          loc.translate('no_songs'),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final song = songs[index];
                  return SongItem(
                    song: song,
                    isSelected: false,
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
                }, childCount: songs.length),
              ),

        // Padding cuối cho mini player
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}
