import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../logic/feed/feed_bloc.dart';
import '../../logic/feed/feed_event.dart';
import '../../data/repositories/post_repository.dart';

import '../../data/models/comment_model.dart';

/// Bottom sheet hiển thị bình luận của bài viết
/// Tách từ feed_screen._showCommentSheet
void showCommentSheet(
  BuildContext context,
  String docId, {
  String postOwnerUserId = '',
}) {
  final commentController = TextEditingController();
  final postRepository = context.read<PostRepository>();
  final feedBloc = context.read<FeedBloc>();

  final theme = Theme.of(context);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: theme.cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return AnimatedPadding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              // Thanh kéo
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Tiêu đề với số lượng comment
              StreamBuilder<QuerySnapshot>(
                stream: postRepository.getCommentsStream(docId),
                builder: (context, snapshot) {
                  final commentCount = snapshot.data?.docs.length ?? 0;
                  return Text(
                    "Bình luận ($commentCount)",
                    style: TextStyle(
                      color: theme.textTheme.titleLarge?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Divider(color: theme.dividerColor),

              // Danh sách bình luận
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: postRepository.getCommentsStream(docId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.tealAccent,
                        ),
                      );
                    }

                    final comments = snapshot.data?.docs ?? [];

                    if (comments.isEmpty) {
                      return const Center(
                        child: Text(
                          "Chưa có bình luận nào\nHãy là người đầu tiên bình luận!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, height: 1.5),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = Comment.fromFirestore(comments[index]);
                        final userName = comment.userName;
                        final text = comment.text;
                        final timeAgo = comment.timeAgo;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.tealAccent.withOpacity(
                                  0.2,
                                ),
                                child: Text(
                                  userName.isNotEmpty
                                      ? userName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.tealAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          userName,
                                          style: TextStyle(
                                            color: theme
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          timeAgo,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      text,
                                      style: TextStyle(
                                        color: theme.textTheme.bodyLarge?.color
                                            ?.withOpacity(0.85),
                                        fontSize: 14,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Ô nhập bình luận
              Divider(color: theme.dividerColor),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        decoration: InputDecoration(
                          hintText: "Viết bình luận...",
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          filled: true,
                          fillColor: Colors.black26,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        if (commentController.text.trim().isNotEmpty) {
                          feedBloc.add(
                            AddComment(
                              postId: docId,
                              text: commentController.text.trim(),
                              postOwnerUserId: postOwnerUserId,
                            ),
                          );
                          commentController.clear();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.tealAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
