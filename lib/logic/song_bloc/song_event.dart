import 'package:equatable/equatable.dart';
import '../../data/models/song_model.dart';

abstract class SongEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// 1. Sự kiện mở app lên hoặc cần làm mới danh sách
class LoadSongs extends SongEvent {}

// 2. Sự kiện thêm bài hát
class AddSongEvent extends SongEvent {
  final Song song;
  AddSongEvent(this.song);
}

// 3. Sự kiện sửa bài hát
class UpdateSongEvent extends SongEvent {
  final Song song;
  UpdateSongEvent(this.song);
}

// 4. Sự kiện xóa bài hát
class DeleteSongEvent extends SongEvent {
  final int id;
  DeleteSongEvent(this.id);
}

// 5. Sự kiện đồng bộ lên Cloud (Firebase)
class SyncToCloudEvent extends SongEvent {}

// 6. Sự kiện tải từ Cloud về máy
class SyncFromCloudEvent extends SongEvent {}