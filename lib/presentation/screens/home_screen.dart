import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/presentation/screens/song_detail_screen.dart';
import '../../logic/song_bloc/song_bloc.dart';
import '../../logic/song_bloc/song_event.dart';
import '../../logic/song_bloc/song_state.dart';
import 'add_edit_song_screen.dart';
import 'login_screen.dart'; // Để làm chức năng đăng xuất

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kho Nhạc Của Tôi"),
        actions: [
          // Nút Đồng bộ LÊN Firebase (Upload)
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            tooltip: "Sao lưu lên Cloud",
            onPressed: () {
              context.read<SongBloc>().add(SyncToCloudEvent());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đang sao lưu lên Firebase...")),
              );
            },
          ),
          // Nút Đồng bộ TỪ Firebase (Download)
          IconButton(
            icon: const Icon(Icons.cloud_download),
            tooltip: "Tải về từ Cloud",
            onPressed: () {
              context.read<SongBloc>().add(SyncFromCloudEvent());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đang tải dữ liệu về máy...")),
              );
            },
          ),
          // Nút Đăng xuất
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      // Nút thêm mới (FAB)
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditSongScreen()),
          );
        },
      ),
      // Phần hiển thị danh sách (Dùng BLoC)
      body: BlocBuilder<SongBloc, SongState>(
        builder: (context, state) {
          if (state is SongLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SongLoaded) {
            if (state.songs.isEmpty) {
              return const Center(
                child: Text("Chưa có bài hát nào.\nHãy bấm dấu + để thêm!",
                    textAlign: TextAlign.center),
              );
            }
            // Hiển thị danh sách
            return ListView.builder(
              itemCount: state.songs.length,
              itemBuilder: (context, index) {
                final song = state.songs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.music_note)),
                    title: Text(song.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(song.artist),
                    // Trong ListView.builder
                    onTap: () {
                      // Chuyển sang màn hình Phát nhạc
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SongDetailScreen(song: song), // Truyền bài hát sang
                        ),
                      );
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // Hiển thị hộp thoại xác nhận Xóa (Yêu cầu bắt buộc của đề bài)
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Xác nhận xóa"),
                            content: Text("Bạn có chắc muốn xóa bài '${song.title}' không?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text("Hủy"),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Gửi sự kiện xóa tới BLoC
                                  context.read<SongBloc>().add(DeleteSongEvent(song.id!));
                                  Navigator.pop(ctx);
                                },
                                child: const Text("Xóa", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          } else if (state is SongError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }
          return Container();
        },
      ),
    );
  }
}