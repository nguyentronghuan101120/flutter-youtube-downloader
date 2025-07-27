import 'package:injectable/injectable.dart';
import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../../domain/entities/download_task.dart';
import '../../domain/entities/download_progress.dart';
import '../../domain/repositories/download_repository.dart';
import '../../core/result/result.dart';
import '../../core/constants/download_status.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/video_info_utils.dart';
import '../../core/utils/download_task_utils.dart';
import '../../core/utils/file_utils.dart';

@LazySingleton(as: DownloadRepository)
class DownloadRepositoryImpl implements DownloadRepository {
  final YoutubeExplode _yt;
  final Map<String, DownloadTask> _downloadTasks = {};
  final Map<String, StreamController<DownloadProgress>> _progressControllers =
      {};
  final Map<String, Timer> _progressTimers = {};
  final Map<String, StreamSubscription> _activeDownloads = {};

  // Integrated chunked download functionality
  final Map<String, Completer<void>> _activeChunkedDownloads = {};

  DownloadRepositoryImpl() : _yt = YoutubeExplode();

  @override
  Future<Result<DownloadTask>> startDownload(StartDownloadParams params) async {
    try {
      developer.log(
        '[download_repository_impl.dart] - Adding to download queue: ${params.url}',
      );

      // Create task with queued status
      final queuedTask = DownloadTask(
        id: _generateTaskId(),
        videoId: params.videoId,
        title: params.title,
        url: params.url,
        format: params.format,
        quality: params.quality,
        outputPath: params.outputPath,
        status: DownloadStatus.queued,
        bytesDownloaded: 0,
        totalBytes: 0,
        progress: 0.0,
        createdAt: DateTime.now(),
        startedAt: null,
      );

      // Add task to map
      _downloadTasks[queuedTask.id] = queuedTask;

      // Start processing queue
      _processQueue();

      // Return queued task immediately
      return Result.success(queuedTask);
    } catch (e) {
      developer.log(
        '[download_repository_impl.dart] - Failed to add to queue: $e',
      );
      return Result.failure('Failed to add to queue: $e');
    }
  }

  void _processQueue() async {
    // Find queued tasks and start downloading them
    final queuedTasks = _downloadTasks.values
        .where((task) => task.status == DownloadStatus.queued)
        .toList();

    // Sort by creation time to maintain order
    queuedTasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    for (final task in queuedTasks) {
      // Check if there are already active downloads (limit concurrent downloads)
      final activeDownloads = _downloadTasks.values
          .where((t) => t.status == DownloadStatus.downloading)
          .length;

      if (activeDownloads < AppConstants.maxConcurrentDownloads) {
        // Use dynamic concurrent limit based on CPU cores
        await _startDownloadFromQueue(task);
      } else {
        // Stop processing if we've reached the limit
        break;
      }
    }
  }

  Future<void> _startDownloadFromQueue(DownloadTask queuedTask) async {
    try {
      // Double-check that the task is still queued
      final currentTask = _downloadTasks[queuedTask.id];
      if (currentTask == null || currentTask.status != DownloadStatus.queued) {
        developer.log(
          '[download_repository_impl.dart] - Task ${queuedTask.id} is no longer queued, skipping',
        );
        return;
      }

      // Update task status to downloading
      final downloadingTask = queuedTask.copyWith(
        status: DownloadStatus.downloading,
        startedAt: DateTime.now(),
      );
      _downloadTasks[queuedTask.id] = downloadingTask;

      developer.log(
        '[download_repository_impl.dart] - Starting download from queue: ${queuedTask.title} (ID: ${queuedTask.id})',
      );

      // Start actual download with chunked approach
      _performChunkedDownloadInBackground(downloadingTask);
    } catch (e) {
      developer.log(
        '[download_repository_impl.dart] - Failed to start download from queue: $e',
      );
      // Mark task as failed
      final failedTask = queuedTask.copyWith(
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
      );
      _downloadTasks[queuedTask.id] = failedTask;
    }
  }

  void _performChunkedDownloadInBackground(DownloadTask task) async {
    try {
      // Extract video ID
      final videoId = VideoInfoUtils.extractVideoId(task.url);
      if (videoId == null) {
        throw Exception('Could not extract video ID from URL');
      }

      // Get stream manifest
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);

      // Find the appropriate stream based on format and quality
      final stream = _findStream(manifest, task.format, task.quality);
      if (stream == null) {
        throw Exception(
          'No stream found for format: ${task.format}, quality: ${task.quality}',
        );
      }

      // Update task with total bytes
      final updatedTask = task.copyWith(totalBytes: stream.size.totalBytes);
      _downloadTasks[task.id] = updatedTask;

      // Perform optimized download
      developer.log(
        '[download_repository_impl.dart] - Starting download for task: ${task.id} - ${task.title}',
      );
      await _performChunkedDownload(updatedTask, stream);

      // Mark as completed
      final completedTask = updatedTask.copyWith(
        status: DownloadStatus.completed,
        completedAt: DateTime.now(),
        progress: 1.0,
        bytesDownloaded: stream.size.totalBytes,
      );
      _downloadTasks[task.id] = completedTask;
      _cleanupProgress(task.id);

      developer.log(
        '[download_repository_impl.dart] - Download completed successfully: ${completedTask.title} (ID: ${task.id}) - Status: ${completedTask.status}',
      );

      // Verify file exists
      final file = File(completedTask.outputPath);
      if (await file.exists()) {
        final fileSize = await file.length();
        developer.log(
          '[download_repository_impl.dart] - File verified: ${file.path} - Size: $fileSize bytes',
        );

        // Try to move file to system Downloads folder on macOS
        await _moveToSystemDownloadsIfNeeded(completedTask);
      } else {
        developer.log(
          '[download_repository_impl.dart] - WARNING: File not found after download: ${file.path}',
        );
      }

      // Process next item in queue
      _processQueue();
    } catch (e) {
      // Mark task as failed
      final failedTask = task.copyWith(
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
      );
      _downloadTasks[task.id] = failedTask;
      _cleanupProgress(task.id);
      developer.log(
        '[download_repository_impl.dart] - Download error: $e (ID: ${task.id})',
      );
      // Process next item in queue even on error
      _processQueue();
    }
  }

  /// Move file to system Downloads folder if on macOS and not already there
  Future<void> _moveToSystemDownloadsIfNeeded(DownloadTask task) async {
    try {
      if (!Platform.isMacOS) {
        return; // Only for macOS
      }

      // Check if file is already in system Downloads
      if (_isInSystemDownloads(task.outputPath)) {
        developer.log(
          '[download_repository_impl.dart] - File already in system Downloads: ${task.outputPath}',
        );
        return;
      }

      // Try to move file to system Downloads
      final newPath = await _moveToSystemDownloads(task.outputPath);
      if (newPath != null) {
        // Update task with new path
        final updatedTask = task.copyWith(outputPath: newPath);
        _downloadTasks[task.id] = updatedTask;

        developer.log(
          '[download_repository_impl.dart] - File moved to system Downloads: $newPath',
        );
      } else {
        developer.log(
          '[download_repository_impl.dart] - Failed to move file to system Downloads: ${task.outputPath}',
        );
      }
    } catch (e) {
      developer.log(
        '[download_repository_impl.dart] - Error moving file to system Downloads: $e',
      );
    }
  }

  /// Move downloaded file to system Downloads folder (macOS only)
  /// Returns the new path if successful, null if failed
  Future<String?> _moveToSystemDownloads(String filePath) async {
    try {
      if (!Platform.isMacOS) {
        developer.log(
          '[download_repository_impl.dart] - _moveToSystemDownloads: Only supported on macOS',
        );
        return null;
      }

      final sourceFile = File(filePath);
      if (!await sourceFile.exists()) {
        developer.log(
          '[download_repository_impl.dart] - _moveToSystemDownloads: Source file does not exist: $filePath',
        );
        return null;
      }

      final systemDownloadsPath = await _getSystemDownloadsPath();
      if (systemDownloadsPath == null) {
        developer.log(
          '[download_repository_impl.dart] - _moveToSystemDownloads: Could not get system downloads path',
        );
        return null;
      }

      final fileName = sourceFile.uri.pathSegments.last;
      final destinationPath = '$systemDownloadsPath/$fileName';

      // Check if file already exists in destination
      final destFile = File(destinationPath);
      if (await destFile.exists()) {
        // Add timestamp to avoid conflicts
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final nameWithoutExt = fileName.substring(0, fileName.lastIndexOf('.'));
        final extension = fileName.substring(fileName.lastIndexOf('.'));
        final newFileName = '${nameWithoutExt}_$timestamp$extension';
        final newDestinationPath = '$systemDownloadsPath/$newFileName';

        await sourceFile.copy(newDestinationPath);
        await sourceFile.delete();

        developer.log(
          '[download_repository_impl.dart] - _moveToSystemDownloads: File moved with timestamp: $newDestinationPath',
        );
        return newDestinationPath;
      } else {
        // Move file directly
        await sourceFile.rename(destinationPath);

        developer.log(
          '[download_repository_impl.dart] - _moveToSystemDownloads: File moved successfully: $destinationPath',
        );
        return destinationPath;
      }
    } catch (e) {
      developer.log(
        '[download_repository_impl.dart] - _moveToSystemDownloads: Error moving file: $e',
      );
      return null;
    }
  }

  /// Get system Downloads path
  Future<String?> _getSystemDownloadsPath() async {
    try {
      if (Platform.isMacOS) {
        final homePath = Platform.environment['HOME'];
        if (homePath != null) {
          final downloadsDir = Directory('$homePath/Downloads');
          if (await downloadsDir.exists()) {
            return downloadsDir.path;
          }
        }
      } else if (Platform.isWindows) {
        final homePath = Platform.environment['USERPROFILE'];
        if (homePath != null) {
          final downloadsDir = Directory('$homePath/Downloads');
          if (await downloadsDir.exists()) {
            return downloadsDir.path;
          }
        }
      } else if (Platform.isLinux) {
        final homePath = Platform.environment['HOME'];
        if (homePath != null) {
          final downloadsDir = Directory('$homePath/Downloads');
          if (await downloadsDir.exists()) {
            return downloadsDir.path;
          }
        }
      }
      return null;
    } catch (e) {
      developer.log(
        '[download_repository_impl.dart] - _getSystemDownloadsPath: Error getting system downloads path: $e',
      );
      return null;
    }
  }

  /// Check if file is in system Downloads folder
  bool _isInSystemDownloads(String filePath) {
    try {
      if (Platform.isMacOS) {
        final homePath = Platform.environment['HOME'];
        if (homePath != null) {
          final downloadsDir = '$homePath/Downloads';
          return filePath.startsWith(downloadsDir);
        }
      } else if (Platform.isWindows) {
        final homePath = Platform.environment['USERPROFILE'];
        if (homePath != null) {
          final downloadsDir = '$homePath/Downloads';
          return filePath.startsWith(downloadsDir);
        }
      } else if (Platform.isLinux) {
        final homePath = Platform.environment['HOME'];
        if (homePath != null) {
          final downloadsDir = '$homePath/Downloads';
          return filePath.startsWith(downloadsDir);
        }
      }
      return false;
    } catch (e) {
      developer.log(
        '[download_repository_impl.dart] - _isInSystemDownloads: Error checking path: $e',
      );
      return false;
    }
  }

  /// Perform chunked download with optimized streaming approach
  Future<void> _performChunkedDownload(
    DownloadTask task,
    dynamic stream,
  ) async {
    try {
      final file = File(task.outputPath);
      final directory = file.parent;

      // Create directory if it doesn't exist
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final totalBytes = stream.size.totalBytes;

      developer.log(
        '[download_repository_impl.dart] - Starting download: ${FileUtils.formatFileSize(totalBytes)} to ${file.path}',
      );

      // Initialize tracking
      _activeChunkedDownloads[task.id] = Completer<void>();

      // Download file using optimized streaming
      await _downloadStreamOptimized(task.id, stream, task.outputPath, (
        progress,
        bytesDownloaded,
      ) {
        // Update task progress
        final currentTask = _downloadTasks[task.id];
        if (currentTask != null) {
          final updatedTask = currentTask.copyWith(
            progress: progress,
            bytesDownloaded: bytesDownloaded,
          );
          _downloadTasks[task.id] = updatedTask;
        }
      });

      // Verify file was created and has correct size
      if (await file.exists()) {
        final fileSize = await file.length();
        developer.log(
          '[download_repository_impl.dart] - Download completed: ${file.path} (${FileUtils.formatFileSize(fileSize)})',
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
        '[download_repository_impl.dart] - Chunked download completed: ${file.path}',
      );
    } catch (e) {
      developer.log(
        '[download_repository_impl.dart] - Chunked download error: $e',
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
              '[download_repository_impl.dart] - Progress: ${(progress * 100).toStringAsFixed(1)}% - $speed - ${FileUtils.formatFileSize(bytesDownloaded)}/${FileUtils.formatFileSize(totalBytes)}',
            );
          }
        }
      }

      await fileStream.flush();
      await fileStream.close();

      // Final progress update
      onProgress(1.0, totalBytes);

      developer.log(
        '[download_repository_impl.dart] - Stream download completed: ${FileUtils.formatFileSize(bytesDownloaded)}',
      );
    } catch (e) {
      developer.log(
        '[download_repository_impl.dart] - Stream download error: $e',
      );
      rethrow;
    }
  }

  /// Cleanup failed download
  Future<void> _cleanupFailedDownload(String taskId, String outputPath) async {
    if (outputPath.isNotEmpty) {
      final file = File(outputPath);
      if (await file.exists()) {
        await file.delete();
        developer.log(
          '[download_repository_impl.dart] - Cleaned up partial file: $outputPath',
        );
      }
    }
  }

  /// Cancel chunked download and cleanup
  Future<void> _cancelChunkedDownload(String taskId) async {
    try {
      final completer = _activeChunkedDownloads[taskId];
      if (completer != null && !completer.isCompleted) {
        completer.complete();
      }

      // Cleanup partial file
      await _cleanupFailedDownload(taskId, '');

      developer.log(
        '[download_repository_impl.dart] - Download cancelled: $taskId',
      );
    } catch (e) {
      developer.log(
        '[download_repository_impl.dart] - Error cancelling download: $e',
      );
    }
  }

  /// Dispose chunked downloads
  void _disposeChunkedDownloads() {
    // Cancel all active downloads
    for (final taskId in _activeChunkedDownloads.keys) {
      _cancelChunkedDownload(taskId);
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

  @override
  Future<Result<DownloadTask>> pauseDownload(String taskId) async {
    try {
      final task = _downloadTasks[taskId];
      if (task == null) {
        return Result.failure('Download task not found');
      }

      final subscription = _activeDownloads[taskId];
      if (subscription != null) {
        await subscription.cancel();
        _activeDownloads.remove(taskId);
      }

      // Cancel chunked download
      await _cancelChunkedDownload(taskId);

      final pausedTask = task.copyWith(
        status: DownloadStatus.paused,
        pausedAt: DateTime.now(),
      );
      _downloadTasks[taskId] = pausedTask;
      _cleanupProgress(taskId);
      return Result.success(pausedTask);
    } catch (e) {
      return Result.failure('Failed to pause download: $e');
    }
  }

  @override
  Future<Result<DownloadTask>> resumeDownload(String taskId) async {
    try {
      final task = _downloadTasks[taskId];
      if (task == null) {
        return Result.failure('Download task not found');
      }

      final resumedTask = task.copyWith(
        status: DownloadStatus.downloading,
        startedAt: DateTime.now(),
      );
      _downloadTasks[taskId] = resumedTask;
      return Result.success(resumedTask);
    } catch (e) {
      return Result.failure('Failed to resume download: $e');
    }
  }

  @override
  Future<Result<void>> cancelDownload(String taskId) async {
    try {
      final task = _downloadTasks[taskId];
      if (task == null) {
        return Result.failure('Download task not found');
      }

      final subscription = _activeDownloads[taskId];
      if (subscription != null) {
        await subscription.cancel();
        _activeDownloads.remove(taskId);
      }

      // Clean up chunk files
      await _cancelChunkedDownload(taskId);

      // Clean up partial file
      final file = File(task.outputPath);
      if (await file.exists()) {
        await file.delete();
      }

      _downloadTasks.remove(taskId);
      _cleanupProgress(taskId);
      return const Result.success(null);
    } catch (e) {
      return Result.failure('Failed to cancel download: $e');
    }
  }

  @override
  Future<Result<DownloadTask>> getDownloadById(String taskId) async {
    try {
      final task = _downloadTasks[taskId];
      if (task == null) {
        return Result.failure('Download task not found');
      }
      return Result.success(task);
    } catch (e) {
      return Result.failure('Failed to get download: $e');
    }
  }

  @override
  Future<Result<List<DownloadTask>>> getAllDownloads() async {
    try {
      final activeDownloads = await getActiveDownloads();
      final queuedDownloads = await getQueuedDownloads();
      final completedDownloads = await getCompletedDownloads();
      final failedDownloads = await getFailedDownloads();

      final allDownloads = <DownloadTask>[];

      activeDownloads.when(
        success: (downloads) => allDownloads.addAll(downloads),
        failure: (_) {},
      );

      queuedDownloads.when(
        success: (downloads) => allDownloads.addAll(downloads),
        failure: (_) {},
      );

      completedDownloads.when(
        success: (downloads) => allDownloads.addAll(downloads),
        failure: (_) {},
      );

      failedDownloads.when(
        success: (downloads) => allDownloads.addAll(downloads),
        failure: (_) {},
      );

      return Result.success(allDownloads);
    } catch (e) {
      return Result.failure('Failed to get all downloads: $e');
    }
  }

  @override
  Future<Result<List<DownloadTask>>> getActiveDownloads() async {
    try {
      final downloads = _downloadTasks.values
          .where((task) => task.status == DownloadStatus.downloading)
          .toList();
      return Result.success(downloads);
    } catch (e) {
      return Result.failure('Failed to get active downloads: $e');
    }
  }

  @override
  Future<Result<List<DownloadTask>>> getQueuedDownloads() async {
    try {
      final downloads = _downloadTasks.values
          .where((task) => task.status == DownloadStatus.queued)
          .toList();
      return Result.success(downloads);
    } catch (e) {
      return Result.failure('Failed to get queued downloads: $e');
    }
  }

  @override
  Future<Result<List<DownloadTask>>> getCompletedDownloads() async {
    try {
      final downloads = _downloadTasks.values
          .where((task) => task.status == DownloadStatus.completed)
          .toList();

      developer.log(
        '[download_repository_impl.dart] - getCompletedDownloads: Found ${downloads.length} completed downloads',
      );

      // Log all tasks for debugging
      developer.log(
        '[download_repository_impl.dart] - All tasks: ${_downloadTasks.length} total',
      );
      for (final task in _downloadTasks.values) {
        developer.log(
          '[download_repository_impl.dart] - Task ${task.id}: ${task.title} - Status: ${task.status}',
        );
      }

      return Result.success(downloads);
    } catch (e) {
      return Result.failure('Failed to get completed downloads: $e');
    }
  }

  @override
  Future<Result<List<DownloadTask>>> getFailedDownloads() async {
    try {
      final downloads = _downloadTasks.values
          .where((task) => task.status == DownloadStatus.failed)
          .toList();
      return Result.success(downloads);
    } catch (e) {
      return Result.failure('Failed to get failed downloads: $e');
    }
  }

  @override
  Future<Result<QueueStatus>> getQueueStatus() async {
    try {
      final active = await getActiveDownloads();
      final queued = await getQueuedDownloads();
      final completed = await getCompletedDownloads();
      final failed = await getFailedDownloads();

      int activeCount = 0;
      int queuedCount = 0;
      int completedCount = 0;
      int failedCount = 0;

      active.when(
        success: (downloads) => activeCount = downloads.length,
        failure: (_) {},
      );

      queued.when(
        success: (downloads) => queuedCount = downloads.length,
        failure: (_) {},
      );

      completed.when(
        success: (downloads) => completedCount = downloads.length,
        failure: (_) {},
      );

      failed.when(
        success: (downloads) => failedCount = downloads.length,
        failure: (_) {},
      );

      final total = activeCount + queuedCount + completedCount + failedCount;

      final status = QueueStatus(
        activeDownloads: activeCount,
        queuedDownloads: queuedCount,
        completedDownloads: completedCount,
        failedDownloads: failedCount,
        totalDownloads: total,
      );

      return Result.success(status);
    } catch (e) {
      return Result.failure('Failed to get queue status: $e');
    }
  }

  @override
  Future<Result<void>> clearCompletedDownloads() async {
    try {
      final completedTasks = await getCompletedDownloads();
      completedTasks.when(
        success: (tasks) {
          for (final task in tasks) {
            _downloadTasks.remove(task.id);
            _cleanupProgress(task.id);
          }
        },
        failure: (_) {},
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failure('Failed to clear completed downloads: $e');
    }
  }

  @override
  Future<Result<void>> clearFailedDownloads() async {
    try {
      final failedTasks = await getFailedDownloads();
      failedTasks.when(
        success: (tasks) {
          for (final task in tasks) {
            _downloadTasks.remove(task.id);
            _cleanupProgress(task.id);
          }
        },
        failure: (_) {},
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failure('Failed to clear failed downloads: $e');
    }
  }

  @override
  Future<Result<void>> setDownloadPriority(String taskId, int priority) async {
    try {
      final task = _downloadTasks[taskId];
      if (task == null) {
        return Result.failure('Download task not found');
      }
      // Implementation for setting priority
      // This would typically involve updating the task with new priority
      return const Result.success(null);
    } catch (e) {
      return Result.failure('Failed to set download priority: $e');
    }
  }

  @override
  Future<Result<void>> reorderDownloadQueue(List<String> taskIds) async {
    try {
      // Implementation for reordering queue
      // This would typically involve updating priority or order
      return const Result.success(null);
    } catch (e) {
      return Result.failure('Failed to reorder download queue: $e');
    }
  }

  @override
  Stream<DownloadProgress> getDownloadProgressStream(String taskId) {
    // Create a new stream controller if it doesn't exist
    if (!_progressControllers.containsKey(taskId)) {
      _progressControllers[taskId] =
          StreamController<DownloadProgress>.broadcast();

      // Start periodic updates for this task
      _startProgressUpdates(taskId);
    }

    return _progressControllers[taskId]!.stream;
  }

  void _startProgressUpdates(String taskId) {
    // Cancel existing timer if any
    _progressTimers[taskId]?.cancel();

    // Create a timer that updates progress every 500ms for optimized performance
    _progressTimers[taskId] = Timer.periodic(
      Duration(milliseconds: AppConstants.progressUpdateInterval),
      (timer) async {
        try {
          final taskResult = await getDownloadById(taskId);
          taskResult.when(
            success: (task) {
              if (task.status == DownloadStatus.downloading &&
                  task.startedAt != null) {
                final speed = DownloadTaskUtils.calculateSpeed(
                  task.bytesDownloaded,
                  task.startedAt!,
                );
                final eta = DownloadTaskUtils.calculateEta(
                  task.bytesDownloaded,
                  task.totalBytes,
                  speed,
                );

                final progress = DownloadProgress(
                  taskId: task.id,
                  progress: task.progress,
                  speed: speed,
                  eta: eta,
                  downloadedBytes: task.bytesDownloaded,
                  totalBytes: task.totalBytes,
                );

                _progressControllers[taskId]?.add(progress);
              } else {
                // Stop updates if download is not active
                timer.cancel();
                _progressTimers.remove(taskId);
                _progressControllers[taskId]?.close();
                _progressControllers.remove(taskId);
              }
            },
            failure: (error) {
              // Stop updates on error
              timer.cancel();
              _progressTimers.remove(taskId);
              _progressControllers[taskId]?.close();
              _progressControllers.remove(taskId);
            },
          );
        } catch (e) {
          // Stop updates on exception
          timer.cancel();
          _progressTimers.remove(taskId);
          _progressControllers[taskId]?.close();
          _progressControllers.remove(taskId);
        }
      },
    );
  }

  /// Generate unique task ID
  String _generateTaskId() {
    return 'task_${DateTime.now().millisecondsSinceEpoch}';
  }

  void _cleanupProgress(String taskId) {
    // Cancel and remove timer
    _progressTimers[taskId]?.cancel();
    _progressTimers.remove(taskId);
    // Close and remove stream controller
    _progressControllers[taskId]?.close();
    _progressControllers.remove(taskId);
  }

  @override
  bool isInSystemDownloads(String filePath) {
    return _isInSystemDownloads(filePath);
  }

  @override
  Future<bool> openFile(String filePath) async {
    try {
      // This would typically use url_launcher or similar package
      developer.log(
        '[download_repository_impl.dart] - Opening file: $filePath',
      );
      // TODO: Implement file opening functionality using url_launcher
      // For now, just return true as placeholder
      return true;
    } catch (e) {
      developer.log('[download_repository_impl.dart] - Error opening file: $e');
      return false;
    }
  }

  @override
  Future<String?> moveToSystemDownloads(String filePath) async {
    return await _moveToSystemDownloads(filePath);
  }

  void dispose() {
    for (final timer in _progressTimers.values) {
      timer.cancel();
    }
    _progressTimers.clear();

    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();

    for (final subscription in _activeDownloads.values) {
      subscription.cancel();
    }
    _activeDownloads.clear();

    // Clean up all chunk files
    _disposeChunkedDownloads();

    _yt.close();
  }
}
