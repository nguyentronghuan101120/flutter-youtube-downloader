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

  /// Checks if a URL is a valid YouTube video URL
  ///
  /// [url] - The URL to validate
  /// Returns true if URL is valid, false otherwise
  bool isValidVideoUrl(String url);

  /// Checks if a URL is a valid YouTube playlist URL
  ///
  /// [url] - The URL to validate
  /// Returns true if URL is valid, false otherwise
  bool isValidPlaylistUrl(String url);

  /// Extracts video ID from YouTube URL
  ///
  /// [url] - The YouTube URL
  /// Returns video ID if found, null otherwise
  String? extractVideoId(String url);

  /// Extracts playlist ID from YouTube URL
  ///
  /// [url] - The YouTube playlist URL
  /// Returns playlist ID if found, null otherwise
  String? extractPlaylistId(String url);
}
