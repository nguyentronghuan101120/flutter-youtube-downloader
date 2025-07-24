import 'package:injectable/injectable.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../../domain/entities/video_info.dart';
import '../../domain/entities/playlist_info.dart';

@lazySingleton
class YouTubeService {
  final YoutubeExplode _yt;
  final Map<String, DateTime> _lastRequestTimes = {};
  final Duration _rateLimitDelay = const Duration(milliseconds: 500);
  final int _maxRetries = 3;
  final Duration _retryDelay = const Duration(seconds: 2);

  YouTubeService() : _yt = YoutubeExplode();

  /// Analyzes a YouTube video with retry mechanism and rate limiting
  ///
  /// [url] - The YouTube video URL
  /// Returns [VideoInfo] with complete metadata
  /// Throws [Exception] if video cannot be analyzed after retries
  Future<VideoInfo> analyzeVideo(String url) async {
    await _enforceRateLimit('video_analysis');

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final videoId = _extractVideoId(url);
        if (videoId == null) {
          throw Exception('Could not extract video ID from URL');
        }

        final video = await _yt.videos.get(videoId);

        return VideoInfo(
          id: video.id.value,
          title: video.title,
          author: video.author,
          duration: video.duration ?? Duration.zero,
          thumbnailUrl: _getBestThumbnailUrl(videoId),
          description: video.description,
          uploadDate: video.uploadDate ?? DateTime.now(),
          viewCount: video.engagement.viewCount,
          tags: video.keywords.toList(),
          url: url,
        );
      } catch (e) {
        if (attempt == _maxRetries) {
          _handleVideoError(e);
        } else {
          await Future.delayed(_retryDelay * attempt);
        }
      }
    }

    throw Exception('Failed to analyze video after $_maxRetries attempts');
  }

  /// Analyzes a YouTube playlist with batch processing and rate limiting
  ///
  /// [playlistUrl] - The YouTube playlist URL
  /// Returns [PlaylistInfo] with video collection
  /// Throws [Exception] if playlist cannot be analyzed
  Future<PlaylistInfo> analyzePlaylist(String playlistUrl) async {
    await _enforceRateLimit('playlist_analysis');

    try {
      final playlistId = _extractPlaylistId(playlistUrl);
      if (playlistId == null) {
        throw Exception('Could not extract playlist ID from URL');
      }

      final playlist = await _yt.playlists.get(playlistId);
      final videos = <VideoInfo>[];

      // Process videos in batches to avoid overwhelming the API
      const batchSize = 5;
      int processedCount = 0;

      await for (final video in _yt.playlists.getVideos(playlistId)) {
        try {
          await _enforceRateLimit('video_analysis');
          final videoInfo = await analyzeVideo(video.url);
          videos.add(videoInfo);
          processedCount++;

          // Add delay between batches
          if (processedCount % batchSize == 0) {
            await Future.delayed(const Duration(seconds: 1));
          }
        } catch (e) {
          // Skip videos that cannot be analyzed
          // debugPrint('Skipping video ${video.id}: $e');
        }
      }

      return PlaylistInfo(
        id: playlist.id.value,
        title: playlist.title,
        description: playlist.description,
        channelName: playlist.author,
        channelId: '', // Default empty string since channelId is not available
        thumbnailUrl: _getBestThumbnailUrl(playlistId),
        videoCount: videos.length,
        videos: videos,
        isPrivate: false, // Default value since isPrivate is not available
        isRegionBlocked: false, // Default value
      );
    } catch (e) {
      throw Exception('Failed to analyze playlist: $e');
    }
  }

  /// Gets video streams for download
  ///
  /// [videoId] - The YouTube video ID
  /// Returns [StreamManifest] with available streams
  Future<StreamManifest> getVideoStreams(String videoId) async {
    await _enforceRateLimit('stream_analysis');

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        return await _yt.videos.streamsClient.getManifest(videoId);
      } catch (e) {
        if (attempt == _maxRetries) {
          throw Exception('Failed to get video streams: $e');
        } else {
          await Future.delayed(_retryDelay * attempt);
        }
      }
    }

    throw Exception('Failed to get video streams after $_maxRetries attempts');
  }

  /// Validates if a URL is a valid YouTube video URL
  bool isValidVideoUrl(String url) {
    final youtubeVideoPattern = RegExp(
      r'^(https?://)?(www\.)?(youtube\.com/watch\?v=|youtu\.be/|youtube\.com/embed/)[a-zA-Z0-9_-]{11}.*$',
      caseSensitive: false,
    );
    return youtubeVideoPattern.hasMatch(url);
  }

  /// Validates if a URL is a valid YouTube playlist URL
  bool isValidPlaylistUrl(String url) {
    final playlistPattern = RegExp(
      r'^(https?://)?(www\.)?(youtube\.com/playlist\?list=|youtube\.com/watch\?.*&list=)[a-zA-Z0-9_-]+.*$',
      caseSensitive: false,
    );
    return playlistPattern.hasMatch(url);
  }

  /// Extracts video ID from YouTube URL
  String? extractVideoId(String url) {
    return _extractVideoId(url);
  }

  /// Extracts playlist ID from YouTube URL
  String? extractPlaylistId(String url) {
    return _extractPlaylistId(url);
  }

  /// Enforces rate limiting for API calls
  Future<void> _enforceRateLimit(String operation) async {
    final now = DateTime.now();
    final lastRequest = _lastRequestTimes[operation];

    if (lastRequest != null) {
      final timeSinceLastRequest = now.difference(lastRequest);
      if (timeSinceLastRequest < _rateLimitDelay) {
        final delay = _rateLimitDelay - timeSinceLastRequest;
        await Future.delayed(delay);
      }
    }

    _lastRequestTimes[operation] = now;
  }

  /// Handles video-specific errors
  void _handleVideoError(dynamic error) {
    if (error is VideoUnavailableException) {
      throw Exception('Video is unavailable or private');
    } else if (error is VideoRequiresPurchaseException) {
      throw Exception('Video requires purchase');
    } else if (error is VideoUnplayableException) {
      throw Exception('Video is unplayable');
    } else {
      throw Exception('Failed to analyze video: $error');
    }
  }

  /// Gets the best thumbnail URL for a video
  String _getBestThumbnailUrl(String videoId) {
    const qualities = ['maxresdefault', 'hqdefault', 'mqdefault', 'sddefault'];

    for (final quality in qualities) {
      final url = 'https://img.youtube.com/vi/$videoId/$quality.jpg';
      return url;
    }

    return 'https://img.youtube.com/vi/$videoId/default.jpg';
  }

  /// Extracts video ID from YouTube URL
  String? _extractVideoId(String url) {
    final patterns = [
      RegExp(
        r'(?:youtube\.com/watch\?v=|youtu\.be/|youtube\.com/embed/)([a-zA-Z0-9_-]{11})',
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }

  /// Extracts playlist ID from YouTube URL
  String? _extractPlaylistId(String url) {
    final patterns = [
      RegExp(
        r'(?:youtube\.com/playlist\?list=|youtube\.com/watch\?.*&list=)([a-zA-Z0-9_-]+)',
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }

  /// Disposes the YouTube client
  void dispose() {
    _yt.close();
  }
}
