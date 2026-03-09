import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/album/album_bloc.dart';
import '../../logic/album/album_event.dart';
import '../screens/add_album_screen.dart';

/// Menu tùy chọn album (sửa / xóa)
/// Chỉ gọi khi user là chủ album
void showAlbumOptionsMenu({
  required BuildContext context,
  required String albumDocId,
  required String albumTitle,
  required String albumCoverUrl,
  required List<String> songIds,
}) {
  final albumBloc = context.read<AlbumBloc>();

  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1E1E1E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Wrap(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      albumCoverUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[800],
                        child: const Icon(Icons.album, color: Colors.white24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      albumTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),

            // --- SỬA ALBUM ---
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white54),
              title: const Text(
                'Sửa Album',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddAlbumScreen(
                      editDocId: albumDocId,
                      editTitle: albumTitle,
                      editCoverUrl: albumCoverUrl,
                      editSongIds: songIds,
                    ),
                  ),
                );
              },
            ),

            // --- XÓA ALBUM ---
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text(
                'Xóa Album',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteAlbum(
                  context: context,
                  albumBloc: albumBloc,
                  albumDocId: albumDocId,
                  albumTitle: albumTitle,
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

/// Dialog xác nhận xóa album
void _confirmDeleteAlbum({
  required BuildContext context,
  required AlbumBloc albumBloc,
  required String albumDocId,
  required String albumTitle,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Xác nhận xóa'),
      content: Text(
        'Bạn có chắc chắn muốn xóa album "$albumTitle" không?\n\nHành động này không thể hoàn tác.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            albumBloc.add(DeleteAlbum(albumDocId));
            Navigator.pop(context); // Quay lại từ album detail
          },
          style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
          child: const Text('Xóa'),
        ),
      ],
    ),
  );
}
