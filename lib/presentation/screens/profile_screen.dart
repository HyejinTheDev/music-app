import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../logic/profile/profile_bloc.dart';
import '../../logic/profile/profile_state.dart';
import '../../l10n/app_localizations.dart';
import 'add_edit_song_screen.dart';
import 'add_album_screen.dart';
import 'history_screen.dart';
import 'favorites_detail_screen.dart';
import 'settings_screen.dart';
import '../widgets/edit_name_dialog.dart';
import '../widgets/profile_menu_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            String displayName = loc.translate('new_artist');
            String email = loc.translate('guest_mode');
            String? photoUrl;

            if (profileState is ProfileLoaded) {
              displayName = profileState.displayName;
              email = profileState.email;
              photoUrl = profileState.photoUrl;
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
                            backgroundImage: photoUrl != null
                                ? NetworkImage(photoUrl)
                                : null,
                            child: photoUrl == null
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
                              onTap: () =>
                                  showEditNameDialog(context, displayName),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.tealAccent.withOpacity(0.15),
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

                  // 4. Đăng xuất
                  ProfileMenuTile(
                    icon: Icons.logout,
                    title: loc.translate('logout'),
                    isExit: true,
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
