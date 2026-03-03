import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/feed/feed_bloc.dart';
import '../../logic/feed/feed_event.dart';
import 'edit_post_sheet.dart';

/// Menu 3 chấm cho bài viết — chỉ người đăng mới sửa/xóa
/// Tách từ post_card.dart
void showPostOptionsMenu(
  BuildContext context,
  Map<String, dynamic> data,
  String docId,
) {
  final user = FirebaseAuth.instance.currentUser;
  final postUserId = data['userId'];
  final isOwner = user != null && postUserId != null && user.uid == postUserId;

  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1E1E1E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            if (isOwner) ...[
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.tealAccent),
                title: const Text(
                  "Chỉnh sửa bài viết",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  showEditPostSheet(context, data, docId);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  "Xóa bài viết",
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  confirmDeletePost(context, docId);
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(
                  Icons.flag_outlined,
                  color: Colors.orangeAccent,
                ),
                title: const Text(
                  "Báo cáo bài viết",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Đã gửi báo cáo. Cảm ơn bạn!"),
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

/// Dialog xác nhận xóa bài viết
void confirmDeletePost(BuildContext context, String docId) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          "Xóa bài viết?",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Bạn có chắc muốn xóa bài viết này? Hành động này không thể hoàn tác.",
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<FeedBloc>().add(DeletePost(docId));
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      );
    },
  );
}
