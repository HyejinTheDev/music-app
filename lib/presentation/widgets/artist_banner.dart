import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/artist_profile.dart';
import '../../data/repositories/auth_repository.dart';
import '../../logic/follow/follow_bloc.dart';
import '../../logic/follow/follow_event.dart';
import '../../logic/follow/follow_state.dart';

/// Banner danh sách nghệ sĩ nổi bật (scroll ngang)
/// Hiển thị tài khoản người dùng duy nhất (nhóm theo userId)
/// Có nút theo dõi / bỏ theo dõi
class ArtistBanner extends StatelessWidget {
  final List<ArtistProfile> artists;
  final Function(ArtistProfile) onTap;

  const ArtistBanner({Key? key, required this.artists, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = context.read<AuthRepository>().currentUserId;

    if (artists.isEmpty) {
      return const SizedBox(height: 140);
    }

    return SizedBox(
      height: 140,
      child: BlocBuilder<FollowBloc, FollowState>(
        builder: (context, followState) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: artists.length,
            itemBuilder: (context, index) {
              final artist = artists[index];
              final isMe = artist.userId == currentUserId;
              final isFollowing = followState.isFollowing(artist.userId);

              return GestureDetector(
                onTap: () => onTap(artist),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 80,
                  child: Column(
                    children: [
                      // Avatar
                      Hero(
                        tag: 'artist_avatar_${artist.userId}',
                        child: Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: artist.avatarUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(artist.avatarUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            border: Border.all(
                              color: isFollowing
                                  ? Colors.tealAccent
                                  : (theme.brightness == Brightness.dark
                                        ? Colors.white24
                                        : Colors.grey.shade300),
                              width: isFollowing ? 2.5 : 2,
                            ),
                          ),
                          child: artist.avatarUrl == null
                              ? Icon(
                                  Icons.person,
                                  size: 32,
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.white24
                                      : Colors.grey.shade400,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Tên nghệ sĩ
                      Text(
                        artist.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              theme.textTheme.bodySmall?.color ??
                              Colors.white70,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),

                      // Nút Theo dõi / Đang theo dõi (không hiện cho chính mình)
                      if (!isMe)
                        GestureDetector(
                          onTap: () {
                            context.read<FollowBloc>().add(
                              ToggleFollow(
                                artistUserId: artist.userId,
                                artistName: artist.displayName,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isFollowing
                                  ? Colors.transparent
                                  : Colors.tealAccent,
                              borderRadius: BorderRadius.circular(12),
                              border: isFollowing
                                  ? Border.all(
                                      color: Colors.grey.shade500,
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Text(
                              isFollowing ? 'Đã theo dõi' : 'Theo dõi',
                              style: TextStyle(
                                color: isFollowing
                                    ? Colors.grey.shade400
                                    : Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
