import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/song_model.dart';
import '../../data/repositories/post_repository.dart';
import '../../logic/feed/feed_bloc.dart';
import '../../logic/feed/feed_state.dart';
import '../widgets/post_card.dart';
import '../widgets/comment_sheet.dart';
import '../widgets/create_post_sheet.dart';

class FeedScreen extends StatelessWidget {
  final AudioPlayer player;
  final Song? currentSong;
  final Function(Song) onPlaySong;
  final List<Song> favoriteSongs;
  final Function(Song) onToggleFavorite;

  const FeedScreen({
    Key? key,
    required this.player,
    this.currentSong,
    required this.onPlaySong,
    required this.favoriteSongs,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<FeedBloc, FeedState>(
      listener: (context, state) {
        if (state is FeedActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.tealAccent.withOpacity(0.8),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is FeedError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Cộng đồng",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_box_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => showCreatePostSheet(
                      context,
                      favoriteSongs: favoriteSongs,
                    ),
                  ),
                ],
              ),
            ),

            // Danh sách bài viết — Stream từ PostRepository
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: context.read<PostRepository>().getPostsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.tealAccent,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Lỗi tải bài viết: ${snapshot.error}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  final docs = List<QueryDocumentSnapshot>.from(
                    snapshot.data?.docs ?? [],
                  );

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "Chưa có bài viết nào\nHãy chia sẻ bài hát đầu tiên!",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, height: 1.5),
                      ),
                    );
                  }

                  // Sắp xếp theo timestamp mới nhất
                  docs.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final aTime = aData['timestamp'] as Timestamp?;
                    final bTime = bData['timestamp'] as Timestamp?;
                    if (aTime == null && bTime == null) return 0;
                    if (aTime == null) return 1;
                    if (bTime == null) return -1;
                    return bTime.compareTo(aTime);
                  });

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final docId = docs[index].id;

                      return PostCard(
                        data: data,
                        docId: docId,
                        currentSong: currentSong,
                        player: player,
                        onPlaySong: onPlaySong,
                        onToggleFavorite: onToggleFavorite,
                        onCommentTap: () => showCommentSheet(context, docId),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
