import 'package:injectable/injectable.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:developer' as developer;
import '../../domain/entities/video_info.dart';
import '../../domain/entities/video_stream.dart';
import '../../domain/entities/audio_stream.dart';
import '../../domain/repositories/video_repository.dart';
import '../../core/utils/video_info_utils.dart';

@LazySingleton(as: VideoRepository)
class VideoRepositoryImpl implements VideoRepository {
  final YoutubeExplode _yt;
  final Map<String, DateTime> _lastRequestTimes = {};
  final Duration _rateLimitDelay = const Duration(milliseconds: 500);
  final int _maxRetries = 3;
  final Duration _retryDelay = const Duration(seconds: 2);

  VideoRepositoryImpl() : _yt = YoutubeExplode();

  @override
  Future<VideoInfo> analyzeVideo(String url) async {
    await _enforceRateLimit('video_analysis');

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final videoId = VideoInfoUtils.extractVideoId(url);
        if (videoId == null) {
          throw Exception('Could not extract video ID from URL');
        }

        final video = await _yt.videos.get(videoId);

        // Get video streams manifest
        final manifest = await _yt.videos.streamsClient.getManifest(videoId);

        // Debug: Print manifest info
        developer.log(
          '[video_repository_impl.dart] - Manifest muxed streams: ${manifest.muxed.length}',
        );
        developer.log(
          '[video_repository_impl.dart] - Manifest audio streams: ${manifest.audioOnly.length}',
        );
        developer.log(
          '[video_repository_impl.dart] - Manifest video streams: ${manifest.videoOnly.length}',
        );

        // Convert real streams to our domain entities
        final videoStreams = <VideoStream>[];
        final audioStreams = <AudioStream>[];

        // Process video-only streams
        for (final stream in manifest.videoOnly) {
          videoStreams.add(
            VideoStream(
              url: stream.url.toString(),
              format: stream.container.name,
              quality: stream.videoQuality.qualityString,
              width: _getVideoWidth(stream.videoQuality),
              height: _getVideoHeight(stream.videoQuality),
              bitrate: stream.bitrate.bitsPerSecond,
              fileSize: _estimateFileSize(
                stream.bitrate.bitsPerSecond,
                video.duration,
              ),
              codec: stream.videoCodec.toString(),
              resolution:
                  '${_getVideoWidth(stream.videoQuality)}x${_getVideoHeight(stream.videoQuality)}',
              fps: _getVideoFps(stream.videoQuality),
            ),
          );
        }

        // Process audio-only streams
        for (final stream in manifest.audioOnly) {
          audioStreams.add(
            AudioStream(
              url: stream.url.toString(),
              format: stream.container.name,
              bitrate: stream.bitrate.bitsPerSecond,
              fileSize: _estimateFileSize(
                stream.bitrate.bitsPerSecond,
                video.duration,
              ),
              codec: stream.audioCodec.toString(),
              channels: _getAudioChannels(stream.audioCodec.toString()),
              sampleRate: _getAudioSampleRate(stream.audioCodec.toString()),
            ),
          );
        }

        // Add muxed streams (video + audio) as video streams
        for (final stream in manifest.muxed) {
          videoStreams.add(
            VideoStream(
              url: stream.url.toString(),
              format: stream.container.name,
              quality: stream.videoQuality.qualityString,
              width: _getVideoWidth(stream.videoQuality),
              height: _getVideoHeight(stream.videoQuality),
              bitrate: stream.bitrate.bitsPerSecond,
              fileSize: _estimateFileSize(
                stream.bitrate.bitsPerSecond,
                video.duration,
              ),
              codec: stream.videoCodec.toString(),
              resolution:
                  '${_getVideoWidth(stream.videoQuality)}x${_getVideoHeight(stream.videoQuality)}',
              fps: _getVideoFps(stream.videoQuality),
            ),
          );
        }

        developer.log(
          '[video_repository_impl.dart] - Created video streams: ${videoStreams.length}',
        );
        developer.log(
          '[video_repository_impl.dart] - Created audio streams: ${audioStreams.length}',
        );

        return VideoInfo(
          id: video.id.value,
          title: video.title,
          author: video.author,
          duration: video.duration ?? Duration.zero,
          thumbnailUrl: _getBestThumbnailUrl(videoId),
          formats: [], // Empty formats list for now
          videoStreams: videoStreams,
          audioStreams: audioStreams,
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

  @override
  Future<List<VideoInfo>> analyzePlaylist(String playlistUrl) async {
    await _enforceRateLimit('playlist_analysis');

    try {
      final playlistId = VideoInfoUtils.extractPlaylistId(playlistUrl);
      if (playlistId == null) {
        throw Exception('Could not extract playlist ID from URL');
      }

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
          developer.log(
            '[video_repository_impl.dart] - Skipping video ${video.id}: $e',
          );
        }
      }

      return videos;
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

  /// Get video width based on quality
  int _getVideoWidth(VideoQuality quality) {
    return switch (quality) {
      VideoQuality.low144 => 256,
      VideoQuality.low240 => 426,
      VideoQuality.medium360 => 640,
      VideoQuality.medium480 => 854,
      VideoQuality.high720 => 1280,
      VideoQuality.high1080 => 1920,
      VideoQuality.high1440 => 2560,
      VideoQuality.high2160 => 3840,
      VideoQuality.high2880 => 5120,
      VideoQuality.high3072 => 5464,
      VideoQuality.high4320 => 7680,
      VideoQuality.unknown => 640,
    };
  }

  /// Get video height based on quality
  int _getVideoHeight(VideoQuality quality) {
    return switch (quality) {
      VideoQuality.low144 => 144,
      VideoQuality.low240 => 240,
      VideoQuality.medium360 => 360,
      VideoQuality.medium480 => 480,
      VideoQuality.high720 => 720,
      VideoQuality.high1080 => 1080,
      VideoQuality.high1440 => 1440,
      VideoQuality.high2160 => 2160,
      VideoQuality.high2880 => 2880,
      VideoQuality.high3072 => 3072,
      VideoQuality.high4320 => 4320,
      VideoQuality.unknown => 360,
    };
  }

  /// Get video FPS based on quality (default to 30fps)
  int _getVideoFps(VideoQuality quality) {
    // Most YouTube videos are 30fps, some are 60fps for higher qualities
    return switch (quality) {
      VideoQuality.high1080 ||
      VideoQuality.high1440 ||
      VideoQuality.high2160 ||
      VideoQuality.high2880 ||
      VideoQuality.high3072 ||
      VideoQuality.high4320 => 60,
      _ => 30,
    };
  }

  /// Get audio channels (default to 2 for stereo)
  int _getAudioChannels(String codec) {
    // Most YouTube audio is stereo (2 channels)
    return 2;
  }

  /// Get audio sample rate (default to 44100Hz)
  int _getAudioSampleRate(String codec) {
    // Most YouTube audio is 44.1kHz
    return 44100;
  }

  /// Estimates file size based on bitrate and duration
  int _estimateFileSize(int bitrate, Duration? duration) {
    final durationInSeconds = duration?.inSeconds ?? 0;
    final sizeInBits = bitrate * durationInSeconds;
    return (sizeInBits / 8).round(); // Convert bits to bytes
  }

  /// Disposes the YouTube client
  void dispose() {
    _yt.close();
  }
}
