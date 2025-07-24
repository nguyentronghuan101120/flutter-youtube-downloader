import 'dart:async';
import 'dart:io';
import 'package:injectable/injectable.dart';
import '../../domain/entities/download_task.dart';
import '../../domain/entities/video_format.dart';
import '../../domain/entities/video_info.dart';

abstract class DownloadDataSource {
  /// Starts a download task
  ///
  /// [task] - The download task to start
  /// [onProgress] - Optional progress callback
  /// Throws [Exception] if download fails to start
  Future<void> startDownload(
    DownloadTask task, {
    Function(double progress, int bytesDownloaded, int totalBytes)? onProgress,
  });

  /// Pauses an active download
  ///
  /// [taskId] - The ID of the task to pause
  /// Throws [Exception] if task not found or cannot be paused
  Future<void> pauseDownload(String taskId);

  /// Resumes a paused download
  ///
  /// [taskId] - The ID of the task to resume
  /// [onProgress] - Optional progress callback
  /// Throws [Exception] if task not found or cannot be resumed
  Future<void> resumeDownload(
    String taskId, {
    Function(double progress, int bytesDownloaded, int totalBytes)? onProgress,
  });

  /// Cancels an active download
  ///
  /// [taskId] - The ID of the task to cancel
  /// Throws [Exception] if task not found
  Future<void> cancelDownload(String taskId);

  /// Gets available formats for a video
  ///
  /// [videoUrl] - The YouTube video URL
  /// Returns list of available formats
  /// Throws [Exception] if video cannot be analyzed
  Future<List<VideoFormat>> getAvailableFormats(String videoUrl);

  /// Gets video information
  ///
  /// [videoUrl] - The YouTube video URL
  /// Returns video information
  /// Throws [Exception] if video cannot be analyzed
  Future<VideoInfo> getVideoInfo(String videoUrl);
}

@LazySingleton(as: DownloadDataSource)
class DownloadDataSourceImpl implements DownloadDataSource {
  final Map<String, StreamSubscription> _activeDownloads = {};

  @override
  Future<void> startDownload(
    DownloadTask task, {
    Function(double progress, int bytesDownloaded, int totalBytes)? onProgress,
  }) async {
    try {
      // Create output directory if it doesn't exist
      final outputDir = Directory(task.outputPath).parent;
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }

      // Simulate download progress
      final totalBytes = 1000000; // 1MB
      int bytesDownloaded = 0;

      final subscription =
          Stream.periodic(const Duration(milliseconds: 100), (i) {
            bytesDownloaded += 10000; // 10KB per tick
            if (bytesDownloaded >= totalBytes) {
              bytesDownloaded = totalBytes;
            }

            final progress = bytesDownloaded / totalBytes;
            onProgress?.call(progress, bytesDownloaded, totalBytes);

            return bytesDownloaded;
          }).listen(
            (data) {
              // Simulate download data
            },
            onError: (error) {
              throw Exception('Download failed: $error');
            },
            onDone: () {
              // Download completed
              _activeDownloads.remove(task.id);
            },
          );

      _activeDownloads[task.id] = subscription;

      // Simulate file writing
      final file = File(task.outputPath);
      await file.writeAsBytes(List.generate(1000000, (i) => i % 256));
    } catch (e) {
      throw Exception('Failed to start download: $e');
    }
  }

  @override
  Future<void> pauseDownload(String taskId) async {
    final subscription = _activeDownloads[taskId];
    if (subscription != null) {
      await subscription.cancel();
      _activeDownloads.remove(taskId);
    }
  }

  @override
  Future<void> resumeDownload(
    String taskId, {
    Function(double progress, int bytesDownloaded, int totalBytes)? onProgress,
  }) async {
    // For now, we'll restart the download
    // In a real implementation, you'd implement resume functionality
    throw UnimplementedError('Resume functionality not implemented yet');
  }

  @override
  Future<void> cancelDownload(String taskId) async {
    final subscription = _activeDownloads[taskId];
    if (subscription != null) {
      await subscription.cancel();
      _activeDownloads.remove(taskId);

      // Delete partial file if it exists
      // Note: You'd need to store the file path in the task
    }
  }

  @override
  Future<List<VideoFormat>> getAvailableFormats(String videoUrl) async {
    try {
      // Mock available formats
      return [
        const VideoFormat(
          format: 'mp4',
          quality: '720p',
          bitrate: 1000000,
          fileSize: 50000000,
          mimeType: 'video/mp4',
          isAudioOnly: false,
        ),
        const VideoFormat(
          format: 'mp4',
          quality: '1080p',
          bitrate: 2000000,
          fileSize: 100000000,
          mimeType: 'video/mp4',
          isAudioOnly: false,
        ),
        const VideoFormat(
          format: 'mp3',
          quality: 'Audio',
          bitrate: 128000,
          fileSize: 5000000,
          mimeType: 'audio/mp3',
          isAudioOnly: true,
        ),
      ];
    } catch (e) {
      throw Exception('Failed to get available formats: $e');
    }
  }

  @override
  Future<VideoInfo> getVideoInfo(String videoUrl) async {
    try {
      final formats = await getAvailableFormats(videoUrl);

      return VideoInfo(
        id: 'mock_video_id',
        title: 'Mock Video Title',
        author: 'Mock Author',
        duration: const Duration(minutes: 5, seconds: 30),
        thumbnailUrl: 'https://example.com/thumbnail.jpg',
        formats: formats,
      );
    } catch (e) {
      throw Exception('Failed to get video info: $e');
    }
  }

  /// Disposes resources
  void dispose() {
    for (final subscription in _activeDownloads.values) {
      subscription.cancel();
    }
    _activeDownloads.clear();
  }
}
