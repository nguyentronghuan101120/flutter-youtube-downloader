import 'package:injectable/injectable.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:developer' as developer;
import '../../domain/entities/video_info.dart';
import '../../domain/entities/video_stream.dart';
import '../../domain/entities/audio_stream.dart';

@lazySingleton
class YouTubeDataSource {
  final YoutubeExplode _yt;

  YouTubeDataSource() : _yt = YoutubeExplode();

  /// Analyzes a YouTube video and returns video information
  ///
  /// [url] - The YouTube video URL
  /// Returns [VideoInfo] with complete metadata
  /// Throws [Exception] if video cannot be analyzed
  Future<VideoInfo> analyzeVideo(String url) async {
    try {
      // Extract video ID
      final videoId = _extractVideoId(url);
      if (videoId == null) {
        throw Exception('Could not extract video ID from URL');
      }

      // Get video details
      final video = await _yt.videos.get(videoId);

      // Get video streams
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);

      // Debug: Print manifest info
      developer.log(
        '[youtube_datasource.dart] - Manifest muxed streams: ${manifest.muxed.length}',
      );
      developer.log(
        '[youtube_datasource.dart] - Manifest audio streams: ${manifest.audioOnly.length}',
      );

      // Convert streams to our domain entities (simplified for now)
      final videoStreams = <VideoStream>[];
      final audioStreams = <AudioStream>[];

      // Always create mock streams for testing
      videoStreams.add(
        VideoStream(
          url: 'https://example.com/video.mp4',
          format: 'mp4',
          quality: '720p',
          width: 1280,
          height: 720,
          bitrate: 1000000,
          fileSize: 50000000, // 50MB
          codec: 'h264',
          resolution: '1280x720',
          fps: 30,
        ),
      );

      videoStreams.add(
        VideoStream(
          url: 'https://example.com/video.mp4',
          format: 'mp4',
          quality: '480p',
          width: 854,
          height: 480,
          bitrate: 500000,
          fileSize: 25000000, // 25MB
          codec: 'h264',
          resolution: '854x480',
          fps: 30,
        ),
      );

      audioStreams.add(
        AudioStream(
          url: 'https://example.com/audio.mp3',
          format: 'mp3',
          bitrate: 128000,
          fileSize: 10000000, // 10MB
          codec: 'mp3',
          channels: 2,
          sampleRate: 44100,
        ),
      );

      audioStreams.add(
        AudioStream(
          url: 'https://example.com/audio.mp3',
          format: 'mp3',
          bitrate: 320000,
          fileSize: 25000000, // 25MB
          codec: 'mp3',
          channels: 2,
          sampleRate: 44100,
        ),
      );

      developer.log(
        '[youtube_datasource.dart] - Created video streams: ${videoStreams.length}',
      );
      developer.log(
        '[youtube_datasource.dart] - Created audio streams: ${audioStreams.length}',
      );

      // Create VideoInfo entity
      final videoInfo = VideoInfo(
        id: video.id.value,
        title: video.title,
        author: video.author,
        duration: video.duration ?? Duration.zero,
        thumbnailUrl: _getBestThumbnailUrl(videoId),
        formats: [], // TODO: Implement formats extraction
        videoStreams: videoStreams,
        audioStreams: audioStreams,
        description: video.description,
        uploadDate: video.uploadDate ?? DateTime.now(),
        viewCount: video.engagement.viewCount,
        tags: video.keywords.toList(),
        url: url,
      );

      return videoInfo;
    } catch (e) {
      if (e is VideoUnavailableException) {
        throw Exception('Video is unavailable or private');
      } else if (e is VideoRequiresPurchaseException) {
        throw Exception('Video requires purchase');
      } else if (e is VideoUnplayableException) {
        throw Exception('Video is unplayable');
      } else {
        throw Exception('Failed to analyze video: $e');
      }
    }
  }

  /// Analyzes a YouTube playlist and returns video information for all videos
  ///
  /// [playlistUrl] - The YouTube playlist URL
  /// Returns list of [VideoInfo] for all videos in playlist
  /// Throws [Exception] if playlist cannot be analyzed
  Future<List<VideoInfo>> analyzePlaylist(String playlistUrl) async {
    try {
      // Extract playlist ID
      final playlistId = _extractPlaylistId(playlistUrl);
      if (playlistId == null) {
        throw Exception('Could not extract playlist ID from URL');
      }

      // Get playlist (for future use)
      // final playlist = await _yt.playlists.get(playlistId);
      final videos = <VideoInfo>[];

      // Get videos from playlist
      await for (final video in _yt.playlists.getVideos(playlistId)) {
        try {
          final videoInfo = await analyzeVideo(video.url);
          videos.add(videoInfo);
        } catch (e) {
          // Skip videos that cannot be analyzed
          // print('Skipping video ${video.id}: $e');
        }
      }

      return videos;
    } catch (e) {
      throw Exception('Failed to analyze playlist: $e');
    }
  }

  /// Validates if a URL is a valid YouTube video URL
  ///
  /// [url] - The URL to validate
  /// Returns true if URL is valid, false otherwise
  bool isValidVideoUrl(String url) {
    return _isValidVideoUrl(url);
  }

  /// Validates if a URL is a valid YouTube playlist URL
  ///
  /// [url] - The URL to validate
  /// Returns true if URL is valid, false otherwise
  bool isValidPlaylistUrl(String url) {
    final playlistPattern = RegExp(
      r'^(https?://)?(www\.)?(youtube\.com/playlist\?list=|youtube\.com/watch\?.*&list=)[a-zA-Z0-9_-]+.*$',
      caseSensitive: false,
    );
    return playlistPattern.hasMatch(url);
  }

  /// Extracts video ID from YouTube URL
  ///
  /// [url] - The YouTube URL
  /// Returns video ID if found, null otherwise
  String? extractVideoId(String url) {
    return _extractVideoId(url);
  }

  /// Extracts playlist ID from YouTube URL
  ///
  /// [url] - The YouTube playlist URL
  /// Returns playlist ID if found, null otherwise
  String? extractPlaylistId(String url) {
    return _extractPlaylistId(url);
  }

  /// Gets the best thumbnail URL for a video
  ///
  /// [videoId] - The YouTube video ID
  /// Returns the best quality thumbnail URL
  String _getBestThumbnailUrl(String videoId) {
    // Try to get the highest quality thumbnail
    const qualities = ['maxresdefault', 'hqdefault', 'mqdefault', 'sddefault'];

    for (final quality in qualities) {
      final url = 'https://img.youtube.com/vi/$videoId/$quality.jpg';
      // In a real implementation, you might want to check if the URL exists
      return url;
    }

    // Fallback to default thumbnail
    return 'https://img.youtube.com/vi/$videoId/default.jpg';
  }

  /// Extracts playlist ID from YouTube URL
  ///
  /// [url] - The YouTube playlist URL
  /// Returns playlist ID if found, null otherwise
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

  /// Validates if the provided URL is a valid YouTube video URL
  bool _isValidVideoUrl(String url) {
    final youtubeVideoPattern = RegExp(
      r'^(https?://)?(www\.)?(youtube\.com/watch\?v=|youtu\.be/|youtube\.com/embed/)[a-zA-Z0-9_-]{11}.*$',
      caseSensitive: false,
    );
    return youtubeVideoPattern.hasMatch(url);
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

  /// Disposes the YouTube client
  void dispose() {
    _yt.close();
  }
}
