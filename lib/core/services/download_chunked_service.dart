import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;
import '../../domain/entities/download_task.dart';
import '../utils/file_utils.dart';
import '../utils/download_task_utils.dart';
import 'download_stream_service.dart';
import 'download_file_service.dart';

class DownloadChunkedService {
  final DownloadStreamService _streamService;
  final DownloadFileService _fileService;
  final Map<String, Completer<void>> _activeChunkedDownloads = {};

  DownloadChunkedService(this._streamService, this._fileService);

  /// Perform chunked download with optimized streaming approach
  Future<void> performChunkedDownload(
    DownloadTask task,
    Function(DownloadTask) onTaskUpdate,
  ) async {
    try {
      final file = File(task.outputPath);
      final directory = file.parent;

      // Create directory if it doesn't exist
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Get stream manifest and find appropriate stream
      final manifest = await _streamService.getStreamManifest(task.url);
      final stream = _streamService.findStream(
        manifest,
        task.format,
        task.quality,
      );

      if (stream == null) {
        throw Exception(
          'No stream found for format: ${task.format}, quality: ${task.quality}',
        );
      }

      final totalBytes = stream.size.totalBytes;

      // Update task with total bytes
      final updatedTask = task.copyWith(totalBytes: totalBytes);
      onTaskUpdate(updatedTask);

      developer.log(
        '[download_chunked_service.dart] - Starting download: ${FileUtils.formatFileSize(totalBytes)} to ${file.path}',
      );

      // Initialize tracking
      _activeChunkedDownloads[task.id] = Completer<void>();

      // Download file using optimized streaming
      await _downloadStreamOptimized(task.id, stream, task.outputPath, (
        progress,
        bytesDownloaded,
      ) {
        // Update task progress
        final currentTask = updatedTask.copyWith(
          progress: progress,
          bytesDownloaded: bytesDownloaded,
        );
        onTaskUpdate(currentTask);
      });

      // Verify file was created and has correct size
      if (await file.exists()) {
        final fileSize = await file.length();
        developer.log(
          '[download_chunked_service.dart] - Download completed: ${file.path} (${FileUtils.formatFileSize(fileSize)})',
        );

        if (fileSize > 0) {
          _activeChunkedDownloads[task.id]?.complete();
        } else {
          throw Exception('Downloaded file is empty');
        }
      } else {
        throw Exception('Downloaded file was not created');
      }

      // Clean up tracking
      _activeChunkedDownloads.remove(task.id);

      developer.log(
        '[download_chunked_service.dart] - Chunked download completed: ${file.path}',
      );
    } catch (e) {
      developer.log(
        '[download_chunked_service.dart] - Chunked download error: $e',
      );

      // Clean up partial files
      await _cleanupFailedDownload(task.id, task.outputPath);
      _activeChunkedDownloads[task.id]?.completeError(e);
      _activeChunkedDownloads.remove(task.id);

      final file = File(task.outputPath);
      if (await file.exists()) {
        await file.delete();
      }

      throw Exception('Chunked download failed: $e');
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
      final videoStream = _streamService.getVideoStream(stream);

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
              '[download_chunked_service.dart] - Progress: ${(progress * 100).toStringAsFixed(1)}% - $speed - ${FileUtils.formatFileSize(bytesDownloaded)}/${FileUtils.formatFileSize(totalBytes)}',
            );
          }
        }
      }

      await fileStream.flush();
      await fileStream.close();

      // Final progress update
      onProgress(1.0, totalBytes);

      developer.log(
        '[download_chunked_service.dart] - Stream download completed: ${FileUtils.formatFileSize(bytesDownloaded)}',
      );
    } catch (e) {
      developer.log(
        '[download_chunked_service.dart] - Stream download error: $e',
      );
      rethrow;
    }
  }

  /// Cleanup failed download
  Future<void> _cleanupFailedDownload(String taskId, String outputPath) async {
    await _fileService.cleanupFailedDownload(outputPath);
  }

  /// Cancel chunked download and cleanup
  Future<void> cancelChunkedDownload(String taskId) async {
    try {
      final completer = _activeChunkedDownloads[taskId];
      if (completer != null && !completer.isCompleted) {
        completer.complete();
      }

      developer.log(
        '[download_chunked_service.dart] - Download cancelled: $taskId',
      );
    } catch (e) {
      developer.log(
        '[download_chunked_service.dart] - Error cancelling download: $e',
      );
    }
  }

  /// Dispose chunked downloads
  void dispose() {
    // Cancel all active downloads
    for (final taskId in _activeChunkedDownloads.keys) {
      cancelChunkedDownload(taskId);
    }
  }
}
