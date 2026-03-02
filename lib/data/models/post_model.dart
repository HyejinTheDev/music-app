import 'package:cloud_firestore/cloud_firestore.dart';
import 'song_model.dart';

/// Model đại diện cho một bài viết trên Feed
class Post {
  final String? id; // Firestore document ID
  final String? userId;
  final String userName;
  final String userAvatar;
  final String caption;
  final Timestamp? timestamp;
  final int likes;
  final int comments;
  final List<String> likedBy;

  // Thông tin bài hát đính kèm
  final int? songId;
  final String songTitle;
  final String songArtist;
  final String songCoverUrl;
  final String songAudioUrl;

  const Post({
    this.id,
    this.userId,
    required this.userName,
    required this.userAvatar,
    required this.caption,
    this.timestamp,
    this.likes = 0,
    this.comments = 0,
    this.likedBy = const [],
    this.songId,
    required this.songTitle,
    required this.songArtist,
    required this.songCoverUrl,
    required this.songAudioUrl,
  });

  /// Tạo Post từ Firestore document
  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      userId: data['userId'],
      userName: data['userName'] ?? 'Ẩn danh',
      userAvatar: data['userAvatar'] ?? 'https://i.pravatar.cc/150?img=12',
      caption: data['caption'] ?? '',
      timestamp: data['timestamp'] as Timestamp?,
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      songId: data['songId'],
      songTitle: data['songTitle'] ?? 'Không rõ',
      songArtist: data['songArtist'] ?? 'Không rõ',
      songCoverUrl: data['songCoverUrl'] ?? '',
      songAudioUrl: data['songAudioUrl'] ?? '',
    );
  }

  /// Chuyển Post thành Map để ghi vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'caption': caption,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
      'likes': likes,
      'comments': comments,
      'likedBy': likedBy,
      'songId': songId,
      'songTitle': songTitle,
      'songArtist': songArtist,
      'songCoverUrl': songCoverUrl,
      'songAudioUrl': songAudioUrl,
    };
  }

  /// Tạo Song tạm từ dữ liệu post (để phát nhạc)
  Song toSong() {
    return Song(
      id: songId,
      title: songTitle,
      artist: songArtist,
      lyrics: '',
      audioUrl: songAudioUrl,
    );
  }

  /// Lấy coverUrl — nếu không có thì dùng getter từ Song
  String get effectiveCoverUrl {
    return songCoverUrl.isNotEmpty ? songCoverUrl : toSong().coverUrl;
  }

  /// Kiểm tra user đã like post chưa
  bool isLikedBy(String? uid) {
    if (uid == null) return false;
    return likedBy.contains(uid);
  }

  /// Tạo bản copy với các giá trị mới
  Post copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? caption,
    Timestamp? timestamp,
    int? likes,
    int? comments,
    List<String>? likedBy,
    int? songId,
    String? songTitle,
    String? songArtist,
    String? songCoverUrl,
    String? songAudioUrl,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      caption: caption ?? this.caption,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      likedBy: likedBy ?? this.likedBy,
      songId: songId ?? this.songId,
      songTitle: songTitle ?? this.songTitle,
      songArtist: songArtist ?? this.songArtist,
      songCoverUrl: songCoverUrl ?? this.songCoverUrl,
      songAudioUrl: songAudioUrl ?? this.songAudioUrl,
    );
  }
}
