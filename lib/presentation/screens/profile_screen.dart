import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/profile/profile_bloc.dart';
import '../../logic/profile/profile_state.dart';
import '../../logic/auth_bloc/auth_bloc.dart';
import '../../logic/auth_bloc/auth_event.dart';
import '../../logic/auth_bloc/auth_state.dart';
import '../../l10n/app_localizations.dart';
import 'add_edit_song_screen.dart';
import 'add_album_screen.dart';
import 'history_screen.dart';
import 'favorites_detail_screen.dart';
import 'settings_screen.dart';
import '../widgets/edit_name_dialog.dart';
import '../widgets/profile_menu_tile.dart';
import 'stats_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => curr is AuthUnauthenticated,
      listener: (context, state) {
        // Khi AuthBloc emit AuthUnauthenticated → navigate về login
        if (state is AuthUnauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, profileState) {
              String displayName = loc.translate('new_artist');
              String email = loc.translate('guest_mode');
              String? photoUrl;
              int followerCount = 0;
              int followingCount = 0;

              if (profileState is ProfileLoaded) {
                displayName = profileState.displayName;
                email = profileState.email;
                photoUrl = profileState.photoUrl;
                followerCount = profileState.followerCount;
                followingCount = profileState.followingCount;
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // 1. Khu vực Avatar + Tên
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.tealAccent,
                            child: CircleAvatar(
                              radius: 52,
                              backgroundColor: theme.scaffoldBackgroundColor,
                              backgroundImage:
                                  photoUrl != null && photoUrl.isNotEmpty
                                  ? NetworkImage(photoUrl)
                                  : null,
                              child: photoUrl == null || photoUrl.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white24,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Tên + nút sửa
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                displayName,
                                style: TextStyle(
                                  color: theme.textTheme.titleLarge?.color,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => showEditProfileDialog(
                                  context,
                                  displayName,
                                  photoUrl,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.tealAccent.withValues(
                                      alpha: 0.15,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.tealAccent,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Follower / Following counts
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildCountColumn(
                                count: followerCount,
                                label: loc.translate('followers'),
                                theme: theme,
                              ),
                              Container(
                                height: 30,
                                width: 1,
                                color: Colors.grey.withValues(alpha: 0.3),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                              ),
                              _buildCountColumn(
                                count: followingCount,
                                label: loc.translate('following'),
                                theme: theme,
                              ),
                            ],
                          ),

                          // Loading indicator khi đang cập nhật
                          if (profileState is ProfileLoading)
                            const Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.tealAccent,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 2. Khu vực QUẢN LÝ NỘI DUNG
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          loc.translate('content_management'),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // NÚT 1: THÊM BÀI HÁT MỚI
                    ContentManagementCard(
                      leadingIcon: Icons.cloud_upload,
                      title: loc.translate('add_song'),
                      subtitle: loc.translate('add_song_sub'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddEditSongScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    // NÚT 2: THÊM ALBUM MỚI
                    ContentManagementCard(
                      leadingIcon: Icons.album,
                      title: loc.translate('add_album'),
                      subtitle: loc.translate('add_album_sub'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddAlbumScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    // 3. Các cài đặt khác
                    ProfileMenuTile(
                      icon: Icons.history,
                      title: loc.translate('history'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HistoryScreen(),
                          ),
                        );
                      },
                    ),
                    ProfileMenuTile(
                      icon: Icons.favorite,
                      title: loc.translate('favorites'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FavoritesDetailScreen(),
                          ),
                        );
                      },
                    ),
                    ProfileMenuTile(
                      icon: Icons.bar_chart,
                      title: 'Thống kê',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StatsScreen(),
                          ),
                        );
                      },
                    ),
                    ProfileMenuTile(
                      icon: Icons.settings,
                      title: loc.translate('settings'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),

                    const Divider(color: Colors.white10, height: 40),

                    // 4. Đăng xuất — dùng AuthBloc thay vì gọi Firebase trực tiếp
                    ProfileMenuTile(
                      icon: Icons.logout,
                      title: loc.translate('logout'),
                      isExit: true,
                      onTap: () {
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Widget hiển thị số đếm (follower/following)
  Widget _buildCountColumn({
    required int count,
    required String label,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }
}
