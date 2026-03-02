import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../logic/profile/profile_bloc.dart';
import '../../logic/profile/profile_event.dart';
import '../../logic/profile/profile_state.dart';
import '../../logic/song_list/song_list_bloc.dart';
import '../../logic/song_list/song_list_event.dart';
import 'add_edit_song_screen.dart';
import 'add_album_screen.dart';
import 'history_screen.dart';
import 'favorites_detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            String displayName = 'Nghệ sĩ mới';
            String email = 'Guest Mode';
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
                            backgroundColor: Colors.black,
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () =>
                                  _showEditNameDialog(context, displayName),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Quản lý nội dung",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // NÚT 1: THÊM BÀI HÁT MỚI
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Card(
                      color: Colors.tealAccent.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.cloud_upload,
                          color: Colors.tealAccent,
                        ),
                        title: const Text(
                          "Thêm bài hát mới",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          "Tải nhạc của bạn lên hệ thống",
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                        trailing: const Icon(
                          Icons.add_circle,
                          color: Colors.tealAccent,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddEditSongScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // NÚT 2: THÊM ALBUM MỚI
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Card(
                      color: Colors.tealAccent.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.album,
                          color: Colors.tealAccent,
                        ),
                        title: const Text(
                          "Thêm album mới",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          "Tạo danh sách phát của riêng bạn",
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                        trailing: const Icon(
                          Icons.add_circle,
                          color: Colors.tealAccent,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddAlbumScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 3. Các cài đặt khác
                  _buildTile(Icons.history, "Lịch sử đã nghe", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    );
                  }),
                  _buildTile(Icons.favorite, "Danh sách yêu thích", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FavoritesDetailScreen(),
                      ),
                    );
                  }),
                  _buildTile(Icons.settings, "Cài đặt", () {}),

                  const Divider(color: Colors.white10, height: 40),

                  // 4. Đăng xuất
                  _buildTile(Icons.logout, "Đăng xuất", () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  }, isExit: true),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Dialog sửa tên hiển thị
  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Sửa tên hiển thị",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Nhập tên mới...",
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.tealAccent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.tealAccent, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != currentName) {
                context.read<ProfileBloc>().add(UpdateDisplayName(newName));
                // Reload danh sách bài hát để cập nhật tên
                context.read<SongListBloc>().add(LoadSongs());
              }
              Navigator.pop(dialogContext);
            },
            child: const Text(
              "Lưu",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isExit = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isExit ? Colors.redAccent : Colors.white70),
      title: Text(
        title,
        style: TextStyle(color: isExit ? Colors.redAccent : Colors.white),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.white24,
        size: 18,
      ),
    );
  }
}
