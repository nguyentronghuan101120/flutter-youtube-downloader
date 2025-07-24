import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/download_task.dart';
import '../constants/download_status.dart';

@lazySingleton
class DownloadService {
  /// Starts a download with progress tracking
  ///
  /// [videoId] - YouTube video ID
  /// [title] - Video title
  /// [url] - Video URL
  /// [format] - Desired format (mp4, mp3, etc.)
  /// [quality] - Desired quality (720p, 1080p, etc.)
  /// [onProgress] - Progress callback
  /// Returns the download task
  Future<DownloadTask> startDownload({
    required String videoId,
    required String title,
    required String url,
    required String format,
    required String quality,
    Function(double progress, int bytesDownloaded, int totalBytes)? onProgress,
  }) async {
    try {
      // Get download directory
      final downloadDir = await _getDownloadDirectory();
      final fileName = _generateFileName(title, format);
      final outputPath = '${downloadDir.path}/$fileName';

      // Create download task
      final task = DownloadTask(
        id: _generateTaskId(),
        videoId: videoId,
        title: title,
        url: url,
        format: format,
        quality: quality,
        outputPath: outputPath,
        status: DownloadStatus.pending,
        bytesDownloaded: 0,
        totalBytes: 0,
        progress: 0.0,
        createdAt: DateTime.now(),
      );

      // For now, return the task
      // Actual download will be handled by repository
      return task;
    } catch (e) {
      throw Exception('Failed to start download: $e');
    }
  }

  /// Gets the download directory
  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final appDir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${appDir.path}/Downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir;
    } else {
      // For desktop platforms
      final downloadDir = Directory('${Directory.current.path}/Downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir;
    }
  }

  /// Generates a unique task ID
  String _generateTaskId() {
    return 'download_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}';
  }

  /// Generates a safe filename
  String _generateFileName(String title, String format) {
    // Remove invalid characters from title
    final safeTitle = title
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .substring(0, title.length > 50 ? 50 : title.length);

    return '$safeTitle.$format';
  }

  /// Formats file size for display
  String formatFileSize(int bytes) {
    if (bytes == 0) return '0 B';

    const units = ['B', 'KB', 'MB', 'GB'];
    double size = bytes.toDouble();
    int unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  /// Formats download speed for display
  String formatDownloadSpeed(int bytesPerSecond) {
    return '${formatFileSize(bytesPerSecond)}/s';
  }

  /// Calculates ETA based on progress and speed
  String calculateETA(double progress, int bytesPerSecond, int totalBytes) {
    if (progress <= 0 || bytesPerSecond <= 0) return 'Unknown';

    final remainingBytes = totalBytes - (totalBytes * progress).round();
    final remainingSeconds = remainingBytes / bytesPerSecond;

    if (remainingSeconds < 60) {
      return '${remainingSeconds.round()}s';
    } else if (remainingSeconds < 3600) {
      return '${(remainingSeconds / 60).round()}m';
    } else {
      return '${(remainingSeconds / 3600).round()}h';
    }
  }
}
