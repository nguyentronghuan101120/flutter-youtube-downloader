import 'package:injectable/injectable.dart';
import '../entities/video_info.dart';
import '../repositories/video_repository.dart';

@injectable
class AnalyzeVideoUseCase {
  final VideoRepository _videoRepository;

  const AnalyzeVideoUseCase({required VideoRepository videoRepository})
    : _videoRepository = videoRepository;

  /// Analyzes a YouTube video URL and returns video information
  ///
  /// [url] - The YouTube video URL to analyze
  /// Returns [VideoInfo] with complete metadata
  /// Throws [Exception] if URL is invalid or analysis fails
  Future<VideoInfo> execute(String url) async {
    try {
      // Validate URL format
      if (!_videoRepository.isValidVideoUrl(url)) {
        throw Exception('Invalid YouTube video URL format');
      }

      // Extract video ID for additional validation
      final videoId = _videoRepository.extractVideoId(url);
      if (videoId == null) {
        throw Exception('Could not extract video ID from URL');
      }

      // Analyze video using repository
      final videoInfo = await _videoRepository.analyzeVideo(url);

      return videoInfo;
    } catch (e) {
      // Re-throw with more descriptive error message
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to analyze video: $e');
    }
  }

  /// Validates if a URL is a valid YouTube video URL
  ///
  /// [url] - The URL to validate
  /// Returns true if URL is valid, false otherwise
  bool isValidVideoUrl(String url) {
    return _videoRepository.isValidVideoUrl(url);
  }

  /// Extracts video ID from YouTube URL
  ///
  /// [url] - The YouTube URL
  /// Returns video ID if found, null otherwise
  String? extractVideoId(String url) {
    return _videoRepository.extractVideoId(url);
  }
}
