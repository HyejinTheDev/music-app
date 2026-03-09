import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/album_repository.dart';
import '../screens/album_detail_screen.dart';

/// Banner danh sách album mới nhất (scroll ngang)
/// Tách từ home_screen._buildAlbumBanner
class AlbumBanner extends StatelessWidget {
  const AlbumBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: StreamBuilder(
        stream: context.read<AlbumRepository>().getAlbumsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.tealAccent),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Chưa có album nào",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            );
          }

          final albums = snapshot.data!.docs;

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final albumData = albums[index].data() as Map<String, dynamic>;
              final title = albumData['title'] ?? 'Không tên';
              final artist = albumData['artist'] ?? 'Nghệ sĩ';
              final coverUrl = albumData['coverUrl'] ?? '';

              return GestureDetector(
                onTap: () {
                  final songIds = List<String>.from(albumData['songIds'] ?? []);
                  final docId = albums[index].id;
                  final userId = albumData['userId'] as String?;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AlbumDetailScreen(
                        albumTitle: title,
                        albumArtist: artist,
                        albumCoverUrl: coverUrl,
                        songIds: songIds,
                        albumDocId: docId,
                        albumUserId: userId,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          coverUrl,
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.album,
                                  color: Colors.white54,
                                  size: 50,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
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
