import '../../data/models/song_model.dart';

abstract class SongListState {}

class SongListInitial extends SongListState {}

class SongListLoading extends SongListState {}

class SongListLoaded extends SongListState {
  final List<Song> songs;
  // Trạng thái này chứa danh sách bài hát để UI hiển thị
  SongListLoaded(this.songs);
}

class SongListError extends SongListState {
  final String message;
  SongListError(this.message);
}