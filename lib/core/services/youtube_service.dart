import 'package:injectable/injectable.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:dio/dio.dart';

@injectable
class YouTubeService {
  final YoutubeExplode _youtubeExplode;
  final Dio _dio;

  // Rate limiting
  static const int _maxRequestsPerMinute = 60;
  static const Duration _rateLimitWindow = Duration(minutes: 1);
  final List<DateTime> _requestTimestamps = [];

  // Retry configuration
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  YouTubeService(this._youtubeExplode, this._dio);

  /// Get video information with retry mechanism and rate limiting
  Future<Video> getVideo(String url) async {
    await _checkRateLimit();

    return _retryOperation(() async {
      return await _youtubeExplode.videos.get(url);
    });
  }

  /// Get playlist information with retry mechanism and rate limiting
  Future<Playlist> getPlaylist(String url) async {
    await _checkRateLimit();

    return _retryOperation(() async {
      return await _youtubeExplode.playlists.get(url);
    });
  }

  /// Get video streams with retry mechanism and rate limiting
  Future<StreamManifest> getVideoStreams(VideoId videoId) async {
    await _checkRateLimit();

    return _retryOperation(() async {
      return await _youtubeExplode.videos.streamsClient.getManifest(videoId);
    });
  }

  /// Get playlist videos with retry mechanism and rate limiting
  Stream<Video> getPlaylistVideos(PlaylistId playlistId) {
    return _youtubeExplode.playlists.getVideos(playlistId);
  }

  /// Validate URL with retry mechanism
  Future<bool> validateUrl(String url) async {
    await _checkRateLimit();

    return _retryOperation(() async {
      try {
        await _youtubeExplode.videos.get(url);
        return true;
      } catch (e) {
        return false;
      }
    });
  }

  /// Generic retry operation with exponential backoff
  Future<T> _retryOperation<T>(Future<T> Function() operation) async {
    int attempts = 0;

    while (attempts < _maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;

        if (attempts >= _maxRetries) {
          rethrow;
        }

        // Exponential backoff
        final delay = Duration(seconds: _retryDelay.inSeconds * attempts);
        await Future.delayed(delay);
      }
    }

    throw Exception('Operation failed after $_maxRetries attempts');
  }

  /// Check and enforce rate limiting
  Future<void> _checkRateLimit() async {
    final now = DateTime.now();

    // Remove old timestamps outside the rate limit window
    _requestTimestamps.removeWhere(
      (timestamp) => now.difference(timestamp) > _rateLimitWindow,
    );

    // Check if we're at the rate limit
    if (_requestTimestamps.length >= _maxRequestsPerMinute) {
      final oldestTimestamp = _requestTimestamps.first;
      final timeToWait = _rateLimitWindow - now.difference(oldestTimestamp);

      if (timeToWait.isNegative == false) {
        await Future.delayed(timeToWait);
      }
    }

    // Add current request timestamp
    _requestTimestamps.add(now);
  }

  /// Get current rate limit status
  Map<String, dynamic> getRateLimitStatus() {
    final now = DateTime.now();

    // Clean up old timestamps
    _requestTimestamps.removeWhere(
      (timestamp) => now.difference(timestamp) > _rateLimitWindow,
    );

    return {
      'currentRequests': _requestTimestamps.length,
      'maxRequests': _maxRequestsPerMinute,
      'windowDuration': _rateLimitWindow.inSeconds,
      'remainingRequests': _maxRequestsPerMinute - _requestTimestamps.length,
    };
  }

  /// Clear rate limit history (useful for testing)
  void clearRateLimitHistory() {
    _requestTimestamps.clear();
  }

  /// Dispose resources
  void dispose() {
    _youtubeExplode.close();
  }
}
