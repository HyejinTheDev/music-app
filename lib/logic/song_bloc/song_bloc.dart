import 'package:flutter_bloc/flutter_bloc.dart';
import 'song_event.dart';
import 'song_state.dart';
import '../../data/repositories/song_repository.dart';

class SongBloc extends Bloc<SongEvent, SongState> {
  final SongRepository songRepository;

  SongBloc({required this.songRepository}) : super(SongLoading()) {

    // Xử lý: Load danh sách
    on<LoadSongs>((event, emit) async {
      emit(SongLoading()); // Bật trạng thái loading
      try {
        final songs = await songRepository.getLocalSongs();
        emit(SongLoaded(songs)); // Trả về danh sách
      } catch (e) {
        emit(SongError("Lỗi tải dữ liệu: $e"));
      }
    });

    // Xử lý: Thêm bài hát
    on<AddSongEvent>((event, emit) async {
      try {
        await songRepository.addSong(event.song);
        add(LoadSongs()); // Thêm xong thì tự động load lại danh sách
      } catch (e) {
        emit(SongError("Không thể thêm bài hát"));
      }
    });

    // Xử lý: Sửa bài hát
    on<UpdateSongEvent>((event, emit) async {
      try {
        await songRepository.updateSong(event.song);
        add(LoadSongs()); // Sửa xong load lại
      } catch (e) {
        emit(SongError("Lỗi cập nhật"));
      }
    });

    // Xử lý: Xóa bài hát
    on<DeleteSongEvent>((event, emit) async {
      try {
        await songRepository.deleteSong(event.id);
        add(LoadSongs()); // Xóa xong load lại
      } catch (e) {
        emit(SongError("Lỗi xóa bài hát"));
      }
    });

    // Xử lý: Đồng bộ LÊN Firebase
    on<SyncToCloudEvent>((event, emit) async {
      try {
        emit(SongLoading());
        await songRepository.syncToCloud();
        add(LoadSongs()); // Đồng bộ xong load lại
      } catch (e) {
        emit(SongError("Lỗi đồng bộ lên Cloud: $e"));
      }
    });

    // Xử lý: Đồng bộ TỪ Firebase về
    on<SyncFromCloudEvent>((event, emit) async {
      try {
        emit(SongLoading());
        await songRepository.syncFromCloud();
        add(LoadSongs()); // Tải xong load lại để thấy dữ liệu mới
      } catch (e) {
        emit(SongError("Lỗi tải từ Cloud: $e"));
      }
    });
  }
}