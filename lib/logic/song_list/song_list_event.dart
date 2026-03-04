abstract class SongListEvent {}

/// Chỉ đọc từ SQLite local — nhanh, không sync cloud
class LoadSongs extends SongListEvent {}

/// Sync từ cloud + load local — dùng khi lần đầu mở app hoặc bấm ☁️
class SyncAndLoadSongs extends SongListEvent {}
