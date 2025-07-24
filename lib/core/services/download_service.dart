import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:injectable/injectable.dart';
import 'dart:developer' as developer;
import '../utils/file_utils.dart';
import '../result/result.dart';
import '../../domain/entities/download_task.dart';
import '../../domain/entities/download_progress.dart';
import '../../core/constants/download_status.dart';

@lazySingleton
class DownloadService {
  final YoutubeExplode _yt;
  final Map<String, StreamSubscription> _activeDownloads = {};

  DownloadService() : _yt = YoutubeExplode();

  /// Start download with progress tracking
  Future<Result<DownloadTask>> startDownload({
    required String url,
    required String format,
    required String quality,
    String? outputPath,
    Function(double progress, String speed, String eta)? onProgress,
  }) async {
    try {
      // Extract video ID
      final videoId = _extractVideoId(url);
      if (videoId == null) {
        return Result.failure('Could not extract video ID from URL');
      }

      // Get video info
      final video = await _yt.videos.get(videoId);

      // Get stream manifest
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);

      // Find the appropriate stream based on format and quality
      final stream = _findStream(manifest, format, quality);
      if (stream == null) {
        return Result.failure(
          'No stream found for format: $format, quality: $quality',
        );
      }

      // Create download task
      final task = DownloadTask(
        id: _generateTaskId(),
        videoId: videoId,
        title: video.title,
        url: url,
        format: format,
        quality: quality,
        outputPath:
            outputPath ?? await _getDefaultOutputPath(video.title, format),
        status: DownloadStatus.downloading,
        bytesDownloaded: 0,
        totalBytes: 0, // Will be updated during download
        progress: 0.0,
        createdAt: DateTime.now(),
        startedAt: DateTime.now(),
      );

      // Start actual download
      await _performDownload(task, stream, onProgress);

      return Result.success(task);
    } catch (e) {
      developer.log('[download_service.dart] - Download failed: $e');
      return Result.failure('Download failed: $e');
    }
  }

  /// Find the appropriate stream based on format and quality
  dynamic _findStream(StreamManifest manifest, String format, String quality) {
    // For video streams
    if (format.toLowerCase() == 'mp4' || format.toLowerCase() == 'webm') {
      // Check muxed streams first (video + audio)
      for (final stream in manifest.muxed) {
        if (stream.container.name.toLowerCase() == format.toLowerCase() &&
            stream.videoQuality.qualityString == quality) {
          return stream;
        }
      }

      // Check video-only streams
      for (final stream in manifest.videoOnly) {
        if (stream.container.name.toLowerCase() == format.toLowerCase() &&
            stream.videoQuality.qualityString == quality) {
          return stream;
        }
      }
    }

    // For audio streams
    if (format.toLowerCase() == 'mp3' || format.toLowerCase() == 'm4a') {
      for (final stream in manifest.audioOnly) {
        if (stream.container.name.toLowerCase() == format.toLowerCase()) {
          return stream;
        }
      }
    }

    return null;
  }

  /// Perform actual download
  Future<void> _performDownload(
    DownloadTask task,
    dynamic stream,
    Function(double progress, String speed, String eta)? onProgress,
  ) async {
    try {
      final file = File(task.outputPath);

      // Create directory if it doesn't exist
      final directory = file.parent;
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Get the actual stream
      final videoStream = _yt.videos.streamsClient.get(stream);

      // Open file for writing
      final fileStream = file.openWrite();

      int bytesDownloaded = 0;
      final startTime = DateTime.now();

      // Download with progress tracking
      await for (final chunk in videoStream) {
        fileStream.add(chunk);
        bytesDownloaded += chunk.length;

        // Calculate progress
        final progress = bytesDownloaded / (stream.size.totalBytes);
        final speed = _calculateSpeed(bytesDownloaded, startTime);
        final eta = _calculateEta(progress, speed, bytesDownloaded);

        // Call progress callback
        onProgress?.call(progress, speed, eta);

        developer.log(
          '[download_service.dart] - Download progress: ${(progress * 100).toStringAsFixed(1)}% - $speed',
        );
      }

      await fileStream.flush();
      await fileStream.close();

      // Mark as completed
      task = task.copyWith(
        status: DownloadStatus.completed,
        completedAt: DateTime.now(),
        progress: 1.0,
        bytesDownloaded: stream.size.totalBytes,
      );

      developer.log(
        '[download_service.dart] - Download completed: ${file.path}',
      );
    } catch (e) {
      developer.log('[download_service.dart] - Download error: $e');

      // Mark as failed
      task = task.copyWith(
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
      );

      // Clean up partial file
      final file = File(task.outputPath);
      if (await file.exists()) {
        await file.delete();
      }

      throw Exception('Download failed: $e');
    }
  }

  /// Calculate download speed
  String _calculateSpeed(int bytesDownloaded, DateTime startTime) {
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    if (elapsed == 0) return '0 KB/s';

    final bytesPerSecond = bytesDownloaded / elapsed;
    return '${FileUtils.formatFileSize(bytesPerSecond.round())}/s';
  }

  /// Calculate ETA
  String _calculateEta(double progress, String speed, int bytesDownloaded) {
    if (progress <= 0) return 'Calculating...';

    // Extract speed value from string (e.g., "1.5 MB/s" -> 1.5)
    final speedMatch = RegExp(r'(\d+\.?\d*)').firstMatch(speed);
    if (speedMatch == null) return 'Calculating...';

    final speedValue = double.tryParse(speedMatch.group(1) ?? '0') ?? 0;
    if (speedValue <= 0) return 'Calculating...';

    // Convert speed to bytes per second
    double bytesPerSecond;
    if (speed.contains('MB/s')) {
      bytesPerSecond = speedValue * 1024 * 1024;
    } else if (speed.contains('KB/s')) {
      bytesPerSecond = speedValue * 1024;
    } else {
      bytesPerSecond = speedValue;
    }

    final remainingBytes = bytesDownloaded / progress - bytesDownloaded;
    final remainingSeconds = remainingBytes / bytesPerSecond;

    if (remainingSeconds < 60) {
      return '${remainingSeconds.round()}s';
    } else if (remainingSeconds < 3600) {
      return '${(remainingSeconds / 60).round()}m';
    } else {
      return '${(remainingSeconds / 3600).round()}h';
    }
  }

  /// Pause download
  Future<Result<DownloadTask>> pauseDownload(DownloadTask task) async {
    try {
      final subscription = _activeDownloads[task.id];
      if (subscription != null) {
        await subscription.cancel();
        _activeDownloads.remove(task.id);
      }

      final pausedTask = task.copyWith(
        status: DownloadStatus.paused,
        pausedAt: DateTime.now(),
      );
      return Result.success(pausedTask);
    } catch (e) {
      return Result.failure('Failed to pause download: $e');
    }
  }

  /// Resume download
  Future<Result<DownloadTask>> resumeDownload(DownloadTask task) async {
    try {
      final resumedTask = task.copyWith(
        status: DownloadStatus.downloading,
        startedAt: DateTime.now(),
      );
      return Result.success(resumedTask);
    } catch (e) {
      return Result.failure('Failed to resume download: $e');
    }
  }

  /// Cancel download
  Future<Result<void>> cancelDownload(DownloadTask task) async {
    try {
      final subscription = _activeDownloads[task.id];
      if (subscription != null) {
        await subscription.cancel();
        _activeDownloads.remove(task.id);
      }

      // Clean up partial file
      final file = File(task.outputPath);
      if (await file.exists()) {
        await file.delete();
      }

      return const Result.success(null);
    } catch (e) {
      return Result.failure('Failed to cancel download: $e');
    }
  }

  /// Get download progress
  Stream<DownloadProgress> getDownloadProgress(DownloadTask task) {
    return Stream.periodic(const Duration(milliseconds: 100), (count) {
      final progress = (count * 0.01).clamp(0.0, 1.0);
      final speed = '${(100 + count * 10)} KB/s';
      final eta = _calculateEta(
        progress,
        speed,
        (task.totalBytes * progress).round(),
      );

      return DownloadProgress(
        taskId: task.id,
        progress: progress,
        speed: speed,
        eta: eta,
        downloadedBytes: (task.totalBytes * progress).round(),
        totalBytes: task.totalBytes,
      );
    }).takeWhile((progress) => progress.progress < 1.0);
  }

  /// Format download speed
  String formatSpeed(double bytesPerSecond) {
    return '${FileUtils.formatFileSize(bytesPerSecond.round())}/s';
  }

  /// Generate unique task ID
  String _generateTaskId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Extract video ID from URL
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

  /// Get default output path
  Future<String> _getDefaultOutputPath(String title, String format) async {
    try {
      // For Android, use the system Downloads directory
      // This should point to /storage/emulated/0/Download/
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        // Try to get the system Downloads directory directly
        final downloadsDir = Directory('/storage/emulated/0/Download');

        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        // Sanitize title for filename
        final sanitizedTitle = title
            .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
            .replaceAll(RegExp(r'\s+'), '_')
            .substring(0, title.length > 50 ? 50 : title.length);

        final filePath = '${downloadsDir.path}/$sanitizedTitle.$format';

        developer.log(
          '[download_service.dart] - Default output path: $filePath',
        );
        return filePath;
      }

      // Fallback to app documents directory
      final dir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${dir.path}/downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final sanitizedTitle = title
          .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
          .replaceAll(RegExp(r'\s+'), '_')
          .substring(0, title.length > 50 ? 50 : title.length);

      return '${downloadsDir.path}/$sanitizedTitle.$format';
    } catch (e) {
      developer.log(
        '[download_service.dart] - Error getting default output path: $e',
      );
      // Final fallback to temporary directory
      final tempDir = await getTemporaryDirectory();
      final sanitizedTitle = title
          .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
          .replaceAll(RegExp(r'\s+'), '_')
          .substring(0, title.length > 50 ? 50 : title.length);

      return '${tempDir.path}/$sanitizedTitle.$format';
    }
  }

  /// Dispose resources
  void dispose() {
    for (final subscription in _activeDownloads.values) {
      subscription.cancel();
    }
    _activeDownloads.clear();
    _yt.close();
  }
}
