import 'package:injectable/injectable.dart';
import '../entities/video_info.dart';
import '../repositories/video_repository.dart';

@injectable
class AnalyzePlaylistUseCase {
  final VideoRepository _videoRepository;

  const AnalyzePlaylistUseCase({required VideoRepository videoRepository})
    : _videoRepository = videoRepository;

  /// Analyzes a YouTube playlist URL and returns video information for all videos
  ///
  /// [playlistUrl] - The YouTube playlist URL to analyze
  /// Returns list of [VideoInfo] for all videos in playlist
  /// Throws [Exception] if URL is invalid or analysis fails
  Future<List<VideoInfo>> execute(String playlistUrl) async {
    try {
      // Validate URL first
      if (!_videoRepository.isValidPlaylistUrl(playlistUrl)) {
        throw Exception('Invalid YouTube playlist URL format');
      }

      // Extract playlist ID for additional validation
      final playlistId = _videoRepository.extractPlaylistId(playlistUrl);
      if (playlistId == null) {
        throw Exception('Could not extract playlist ID from URL');
      }

      // Analyze playlist using repository
      final videos = await _videoRepository.analyzePlaylist(playlistUrl);

      return videos;
    } catch (e) {
      // Re-throw with more descriptive error message
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to analyze playlist: $e');
    }
  }

  /// Validates if a URL is a valid YouTube playlist URL
  ///
  /// [url] - The URL to validate
  /// Returns true if URL is valid, false otherwise
  bool isValidPlaylistUrl(String url) {
    return _videoRepository.isValidPlaylistUrl(url);
  }

  /// Extracts playlist ID from YouTube URL
  ///
  /// [url] - The YouTube playlist URL
  /// Returns playlist ID if found, null otherwise
  String? extractPlaylistId(String url) {
    return _videoRepository.extractPlaylistId(url);
  }
}
