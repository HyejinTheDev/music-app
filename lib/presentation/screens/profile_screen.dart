import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_edit_song_screen.dart'; // Import màn hình thêm nhạc

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView( // Thêm scroll để không bị tràn màn hình
          child: Column(
            children: [
              const SizedBox(height: 40),
              // 1. Khu vực Avatar
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.tealAccent,
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.black,
                        backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                        child: user?.photoURL == null ? const Icon(Icons.person, size: 50, color: Colors.white24) : null,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      user?.displayName ?? "Nghệ sĩ mới",
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user?.email ?? "Guest Mode",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 2. Khu vực QUẢN LÝ NHẠC (Tính năng bạn muốn)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Quản lý nội dung", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
              
              // Nút Thêm nhạc nổi bật
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Card(
                  color: Colors.tealAccent.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: const Icon(Icons.cloud_upload, color: Colors.tealAccent),
                    title: const Text("Thêm bài hát mới", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: const Text("Tải nhạc của bạn lên hệ thống", style: TextStyle(color: Colors.white60, fontSize: 12)),
                    trailing: const Icon(Icons.add_circle, color: Colors.tealAccent),
                    onTap: () {
                      // Chuyển sang màn hình thêm nhạc
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddEditSongScreen()),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // 3. Các cài đặt khác
              _buildTile(Icons.history, "Lịch sử đã nghe", () {}),
              _buildTile(Icons.favorite, "Danh sách yêu thích", () {}),
              _buildTile(Icons.settings, "Cài đặt", () {}),
              
              const Divider(color: Colors.white10, height: 40),

              // 4. Đăng xuất
              _buildTile(Icons.logout, "Đăng xuất", () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }, isExit: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, VoidCallback onTap, {bool isExit = false}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isExit ? Colors.redAccent : Colors.white70),
      title: Text(title, style: TextStyle(color: isExit ? Colors.redAccent : Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
    );
  }
}