import '../entities/video_info.dart';

abstract class VideoRepository {
  /// Analyzes a YouTube video URL and returns video information
  ///
  /// [url] - The YouTube video URL to analyze
  /// Returns [VideoInfo] with complete metadata
  /// Throws [Exception] if URL is invalid or network fails
  Future<VideoInfo> analyzeVideo(String url);

  /// Analyzes multiple videos from a playlist URL
  ///
  /// [playlistUrl] - The YouTube playlist URL
  /// Returns list of [VideoInfo] for all videos in playlist
  /// Throws [Exception] if URL is invalid or network fails
  Future<List<VideoInfo>> analyzePlaylist(String playlistUrl);
}
