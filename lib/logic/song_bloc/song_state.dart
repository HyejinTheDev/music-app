import 'package:equatable/equatable.dart';
import '../../data/models/song_model.dart';

abstract class SongState extends Equatable {
  @override
  List<Object> get props => [];
}

// Trạng thái đang tải (hiện vòng xoay Loading)
class SongLoading extends SongState {}

// Trạng thái đã tải xong (hiện danh sách bài hát)
class SongLoaded extends SongState {
  final List<Song> songs;
  SongLoaded(this.songs);

  @override
  List<Object> get props => [songs];
}

// Trạng thái lỗi (hiện thông báo đỏ)
class SongError extends SongState {
  final String message;
  SongError(this.message);

  @override
  List<Object> get props => [message];
}