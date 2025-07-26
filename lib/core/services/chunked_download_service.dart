import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../utils/download_task_utils.dart';
import '../utils/file_utils.dart';

/// Service for handling optimized downloads with progress tracking
class ChunkedDownloadService {
  final YoutubeExplode _yt;
  final Map<String, Completer<void>> _activeDownloads = {};

  ChunkedDownloadService() : _yt = YoutubeExplode();

  /// Download file using optimized streaming approach
  Future<void> downloadFile({
    required String taskId,
    required dynamic stream,
    required String outputPath,
    required Function(double progress, int bytesDownloaded) onProgress,
  }) async {
    try {
      final file = File(outputPath);
      final directory = file.parent;

      // Create directory if it doesn't exist
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final totalBytes = stream.size.totalBytes;

      developer.log(
        '[chunked_download_service.dart] - Starting download: ${FileUtils.formatFileSize(totalBytes)} to ${file.path}',
      );

      // Initialize tracking
      _activeDownloads[taskId] = Completer<void>();

      // Download file using optimized streaming
      await _downloadStreamOptimized(taskId, stream, outputPath, onProgress);

      // Verify file was created and has correct size
      if (await file.exists()) {
        final fileSize = await file.length();
        developer.log(
          '[chunked_download_service.dart] - Download completed: ${file.path} (${FileUtils.formatFileSize(fileSize)})',
        );

        if (fileSize > 0) {
          _activeDownloads[taskId]?.complete();
        } else {
          throw Exception('Downloaded file is empty');
        }
      } else {
        throw Exception('Downloaded file was not created');
      }

      // Clean up tracking
      _activeDownloads.remove(taskId);
    } catch (e) {
      developer.log('[chunked_download_service.dart] - Download error: $e');
      await _cleanupFailedDownload(taskId, outputPath);
      _activeDownloads[taskId]?.completeError(e);
      _activeDownloads.remove(taskId);
      throw Exception('Download failed: $e');
    }
  }

  /// Download stream with optimized progress tracking
  Future<void> _downloadStreamOptimized(
    String taskId,
    dynamic stream,
    String outputPath,
    Function(double progress, int bytesDownloaded) onProgress,
  ) async {
    try {
      final file = File(outputPath);
      final fileStream = file.openWrite();

      // Get the video stream
      final videoStream = _yt.videos.streamsClient.get(stream);

      int bytesDownloaded = 0;
      final totalBytes = stream.size.totalBytes;
      final startTime = DateTime.now();
      int lastProgressUpdate = 0;

      await for (final chunk in videoStream) {
        fileStream.add(chunk);
        bytesDownloaded += chunk.length;

        // Calculate progress
        final progress = totalBytes > 0 ? bytesDownloaded / totalBytes : 0.0;

        // Update progress every 100KB to avoid too frequent updates
        if (bytesDownloaded - lastProgressUpdate >= 100 * 1024) {
          onProgress(progress, bytesDownloaded);
          lastProgressUpdate = bytesDownloaded;

          // Log progress every 1MB
          if (bytesDownloaded % (1024 * 1024) < chunk.length) {
            final speed = DownloadTaskUtils.calculateSpeed(
              bytesDownloaded,
              startTime,
            );
            developer.log(
              '[chunked_download_service.dart] - Progress: ${(progress * 100).toStringAsFixed(1)}% - $speed - ${FileUtils.formatFileSize(bytesDownloaded)}/${FileUtils.formatFileSize(totalBytes)}',
            );
          }
        }
      }

      await fileStream.flush();
      await fileStream.close();

      // Final progress update
      onProgress(1.0, totalBytes);

      developer.log(
        '[chunked_download_service.dart] - Stream download completed: ${FileUtils.formatFileSize(bytesDownloaded)}',
      );
    } catch (e) {
      developer.log(
        '[chunked_download_service.dart] - Stream download error: $e',
      );
      rethrow;
    }
  }

  /// Cancel download and cleanup
  Future<void> cancelDownload(String taskId) async {
    try {
      final completer = _activeDownloads[taskId];
      if (completer != null && !completer.isCompleted) {
        completer.complete();
      }

      // Cleanup partial file
      await _cleanupFailedDownload(taskId, '');

      developer.log(
        '[chunked_download_service.dart] - Download cancelled: $taskId',
      );
    } catch (e) {
      developer.log(
        '[chunked_download_service.dart] - Error cancelling download: $e',
      );
    }
  }

  /// Cleanup failed download
  Future<void> _cleanupFailedDownload(String taskId, String outputPath) async {
    if (outputPath.isNotEmpty) {
      final file = File(outputPath);
      if (await file.exists()) {
        await file.delete();
        developer.log(
          '[chunked_download_service.dart] - Cleaned up partial file: $outputPath',
        );
      }
    }
  }

  /// Get download statistics
  Map<String, dynamic> getDownloadStats(String taskId) {
    final completer = _activeDownloads[taskId];

    return {
      'isActive': completer != null && !completer.isCompleted,
      'isCompleted': completer?.isCompleted ?? false,
    };
  }

  /// Dispose service
  void dispose() {
    // Cancel all active downloads
    for (final taskId in _activeDownloads.keys) {
      cancelDownload(taskId);
    }

    _yt.close();
  }
}
