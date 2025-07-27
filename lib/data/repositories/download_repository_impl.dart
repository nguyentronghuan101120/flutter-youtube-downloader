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
import '../../core/services/download_queue_manager.dart';
import '../../core/services/download_progress_service.dart';
import '../../core/services/download_file_service.dart';
import '../../core/services/download_stream_service.dart';
import '../../core/services/download_chunked_service.dart';

@LazySingleton(as: DownloadRepository)
class DownloadRepositoryImpl implements DownloadRepository {
  final YoutubeExplode _yt;
  late final DownloadQueueManager _queueManager;
  late final DownloadProgressService _progressService;
  late final DownloadFileService _fileService;
  late final DownloadStreamService _streamService;
  late final DownloadChunkedService _chunkedService;
  final Map<String, StreamSubscription> _activeDownloads = {};

  DownloadRepositoryImpl() : _yt = YoutubeExplode() {
    _initializeServices();
  }

  void _initializeServices() {
    _fileService = DownloadFileService();
    _streamService = DownloadStreamService(_yt);
    _chunkedService = DownloadChunkedService(_streamService, _fileService);
    _queueManager = DownloadQueueManager(_startDownloadFromQueue);
    _progressService = DownloadProgressService(_queueManager.getTask);
  }

  @override
  Future<Result<DownloadTask>> startDownload(StartDownloadParams params) async {
    try {
      developer.log(
        '[download_repository_impl.dart] - Adding to download queue: ${params.url}',
      );

      // Create task with queued status
      final queuedTask = DownloadTask(
        id: _queueManager.generateTaskId(),
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

      // Add task to queue
      await _queueManager.addToQueue(queuedTask);

      // Return queued task immediately
      return Result.success(queuedTask);
    } catch (e) {
      developer.log(
        '[download_repository_impl.dart] - Failed to add to queue: $e',
      );
      return Result.failure('Failed to add to queue: $e');
    }
  }

  Future<void> _startDownloadFromQueue(DownloadTask task) async {
    try {
      developer.log(
        '[download_repository_impl.dart] - Starting download from queue: ${task.title} (ID: ${task.id})',
      );

      // Start actual download with chunked approach
      _performChunkedDownloadInBackground(task);
    } catch (e) {
      developer.log(
        '[download_repository_impl.dart] - Failed to start download from queue: $e',
      );
      // Mark task as failed
      final failedTask = task.copyWith(
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
      );
      _queueManager.updateTask(failedTask);
    }
  }

  void _performChunkedDownloadInBackground(DownloadTask task) async {
    try {
      developer.log(
        '[download_repository_impl.dart] - Starting download for task: ${task.id} - ${task.title}',
      );

      // Perform optimized download
      await _chunkedService.performChunkedDownload(task, (updatedTask) {
        _queueManager.updateTask(updatedTask);
      });

      // Mark as completed
      final completedTask = task.copyWith(
        status: DownloadStatus.completed,
        completedAt: DateTime.now(),
        progress: 1.0,
        bytesDownloaded: task.totalBytes,
      );
      _queueManager.updateTask(completedTask);
      _progressService.cleanupProgress(task.id);

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
      _queueManager.onTaskCompleted(task.id);
    } catch (e) {
      // Mark task as failed
      final failedTask = task.copyWith(
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
      );
      _queueManager.updateTask(failedTask);
      _progressService.cleanupProgress(task.id);
      developer.log(
        '[download_repository_impl.dart] - Download error: $e (ID: ${task.id})',
      );
      // Process next item in queue even on error
      _queueManager.onTaskCompleted(task.id);
    }
  }

  /// Move file to system Downloads folder if on macOS and not already there
  Future<void> _moveToSystemDownloadsIfNeeded(DownloadTask task) async {
    try {
      final newPath = await _fileService.moveToSystemDownloadsIfNeeded(
        task.outputPath,
      );
      if (newPath != null && newPath != task.outputPath) {
        // Update task with new path
        final updatedTask = task.copyWith(outputPath: newPath);
        _queueManager.updateTask(updatedTask);
      }
    } catch (e) {
      developer.log(
        '[download_repository_impl.dart] - Error moving file to system Downloads: $e',
      );
    }
  }

  @override
  Future<Result<DownloadTask>> pauseDownload(String taskId) async {
    try {
      final task = _queueManager.getTask(taskId);
      if (task == null) {
        return Result.failure('Download task not found');
      }

      final subscription = _activeDownloads[taskId];
      if (subscription != null) {
        await subscription.cancel();
        _activeDownloads.remove(taskId);
      }

      // Cancel chunked download
      await _chunkedService.cancelChunkedDownload(taskId);

      final pausedTask = task.copyWith(
        status: DownloadStatus.paused,
        pausedAt: DateTime.now(),
      );
      _queueManager.updateTask(pausedTask);
      _progressService.cleanupProgress(taskId);
      return Result.success(pausedTask);
    } catch (e) {
      return Result.failure('Failed to pause download: $e');
    }
  }

  @override
  Future<Result<DownloadTask>> resumeDownload(String taskId) async {
    try {
      final task = _queueManager.getTask(taskId);
      if (task == null) {
        return Result.failure('Download task not found');
      }

      final resumedTask = task.copyWith(
        status: DownloadStatus.downloading,
        startedAt: DateTime.now(),
      );
      _queueManager.updateTask(resumedTask);
      return Result.success(resumedTask);
    } catch (e) {
      return Result.failure('Failed to resume download: $e');
    }
  }

  @override
  Future<Result<void>> cancelDownload(String taskId) async {
    try {
      final task = _queueManager.getTask(taskId);
      if (task == null) {
        return Result.failure('Download task not found');
      }

      final subscription = _activeDownloads[taskId];
      if (subscription != null) {
        await subscription.cancel();
        _activeDownloads.remove(taskId);
      }

      // Clean up chunk files
      await _chunkedService.cancelChunkedDownload(taskId);

      // Clean up partial file
      final file = File(task.outputPath);
      if (await file.exists()) {
        await file.delete();
      }

      _queueManager.removeTask(taskId);
      _progressService.cleanupProgress(taskId);
      return const Result.success(null);
    } catch (e) {
      return Result.failure('Failed to cancel download: $e');
    }
  }

  @override
  Future<Result<DownloadTask>> getDownloadById(String taskId) async {
    try {
      final task = _queueManager.getTask(taskId);
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
      final downloads = _queueManager.getTasksByStatus(
        DownloadStatus.downloading,
      );
      return Result.success(downloads);
    } catch (e) {
      return Result.failure('Failed to get active downloads: $e');
    }
  }

  @override
  Future<Result<List<DownloadTask>>> getQueuedDownloads() async {
    try {
      final downloads = _queueManager.getTasksByStatus(DownloadStatus.queued);
      return Result.success(downloads);
    } catch (e) {
      return Result.failure('Failed to get queued downloads: $e');
    }
  }

  @override
  Future<Result<List<DownloadTask>>> getCompletedDownloads() async {
    try {
      final downloads = _queueManager.getTasksByStatus(
        DownloadStatus.completed,
      );

      developer.log(
        '[download_repository_impl.dart] - getCompletedDownloads: Found ${downloads.length} completed downloads',
      );

      // Log all tasks for debugging
      final allTasks = _queueManager.getAllTasks();
      developer.log(
        '[download_repository_impl.dart] - All tasks: ${allTasks.length} total',
      );
      for (final task in allTasks.values) {
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
      final downloads = _queueManager.getTasksByStatus(DownloadStatus.failed);
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
            _queueManager.removeTask(task.id);
            _progressService.cleanupProgress(task.id);
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
            _queueManager.removeTask(task.id);
            _progressService.cleanupProgress(task.id);
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
      final task = _queueManager.getTask(taskId);
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
    return _progressService.getProgressStream(taskId);
  }

  @override
  bool isInSystemDownloads(String filePath) {
    return _fileService.isInSystemDownloads(filePath);
  }

  @override
  Future<bool> openFile(String filePath) async {
    return await _fileService.openFile(filePath);
  }

  @override
  Future<String?> moveToSystemDownloads(String filePath) async {
    return await _fileService.moveToSystemDownloads(filePath);
  }

  void dispose() {
    for (final subscription in _activeDownloads.values) {
      subscription.cancel();
    }
    _activeDownloads.clear();

    _progressService.dispose();
    _chunkedService.dispose();
    _streamService.dispose();
  }
}
