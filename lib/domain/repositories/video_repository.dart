import '../entities/video_info.dart';
import '../entities/playlist_info.dart';

abstract class VideoRepository {
  /// Phân tích video từ URL và trả về thông tin chi tiết
  Future<VideoInfo> getVideoInfo(String url);

  /// Phân tích playlist từ URL và trả về danh sách video
  Future<PlaylistInfo> getPlaylistInfo(String url);

  /// Lấy danh sách video từ playlist ID
  Future<List<VideoInfo>> getPlaylistVideos(String playlistId);

  /// Validate URL có phải là YouTube URL hợp lệ không
  Future<bool> isValidYouTubeUrl(String url);

  /// Trích xuất video ID từ URL
  Future<String> extractVideoId(String url);

  /// Trích xuất playlist ID từ URL
  Future<String> extractPlaylistId(String url);
}
