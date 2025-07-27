import 'dart:developer' as developer;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../utils/video_info_utils.dart';

class DownloadStreamService {
  final YoutubeExplode _yt;

  DownloadStreamService(this._yt);

  /// Extract video ID and get stream manifest
  Future<StreamManifest> getStreamManifest(String url) async {
    try {
      final videoId = VideoInfoUtils.extractVideoId(url);
      if (videoId == null) {
        throw Exception('Could not extract video ID from URL');
      }

      developer.log(
        '[download_stream_service.dart] - Getting stream manifest for video ID: $videoId',
      );

      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      return manifest;
    } catch (e) {
      developer.log(
        '[download_stream_service.dart] - Error getting stream manifest: $e',
      );
      rethrow;
    }
  }

  /// Find the appropriate stream based on format and quality
  dynamic findStream(StreamManifest manifest, String format, String quality) {
    try {
      // For video streams
      if (format.toLowerCase() == 'mp4' || format.toLowerCase() == 'webm') {
        // Check muxed streams first (video + audio)
        for (final stream in manifest.muxed) {
          if (stream.container.name.toLowerCase() == format.toLowerCase() &&
              stream.videoQuality.qualityString == quality) {
            developer.log(
              '[download_stream_service.dart] - Found muxed stream: ${stream.container.name} - ${stream.videoQuality.qualityString}',
            );
            return stream;
          }
        }

        // Check video-only streams
        for (final stream in manifest.videoOnly) {
          if (stream.container.name.toLowerCase() == format.toLowerCase() &&
              stream.videoQuality.qualityString == quality) {
            developer.log(
              '[download_stream_service.dart] - Found video-only stream: ${stream.container.name} - ${stream.videoQuality.qualityString}',
            );
            return stream;
          }
        }
      }

      // For audio streams
      if (format.toLowerCase() == 'mp3' || format.toLowerCase() == 'm4a') {
        for (final stream in manifest.audioOnly) {
          if (stream.container.name.toLowerCase() == format.toLowerCase()) {
            developer.log(
              '[download_stream_service.dart] - Found audio stream: ${stream.container.name}',
            );
            return stream;
          }
        }
      }

      developer.log(
        '[download_stream_service.dart] - No stream found for format: $format, quality: $quality',
      );
      return null;
    } catch (e) {
      developer.log(
        '[download_stream_service.dart] - Error finding stream: $e',
      );
      return null;
    }
  }

  /// Get video stream for downloading
  Stream<List<int>> getVideoStream(dynamic stream) {
    try {
      return _yt.videos.streamsClient.get(stream);
    } catch (e) {
      developer.log(
        '[download_stream_service.dart] - Error getting video stream: $e',
      );
      rethrow;
    }
  }

  /// Close YouTube Explode instance
  void dispose() {
    _yt.close();
  }
}
