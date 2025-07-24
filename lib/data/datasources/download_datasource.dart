import 'package:injectable/injectable.dart';
import 'dart:developer' as developer;

import 'dart:async';
import '../../domain/entities/download_task.dart';
import '../../domain/entities/video_info.dart';
import '../../domain/repositories/download_repository.dart';
import '../../core/constants/download_status.dart';
import '../../core/services/download_service.dart';

abstract class DownloadDataSource {
  /// Starts a new download task
  ///
  /// [params] - Download parameters including URL, format, quality, etc.
  /// Returns [DownloadTask] with initial status
  /// Throws [Exception] if download cannot be started
  Future<DownloadTask> startDownload(StartDownloadParams params);

  /// Pauses an active download
  ///
  /// [taskId] - The ID of the download task to pause
  /// Returns updated [DownloadTask] with paused status
  /// Throws [Exception] if task not found or cannot be paused
  Future<DownloadTask> pauseDownload(String taskId);

  /// Resumes a paused download
  ///
  /// [taskId] - The ID of the download task to resume
  /// Returns updated [DownloadTask] with downloading status
  /// Throws [Exception] if task not found or cannot be resumed
  Future<DownloadTask> resumeDownload(String taskId);

  /// Cancels a download and removes it from queue
  ///
  /// [taskId] - The ID of the download task to cancel
  /// Throws [Exception] if task not found or cannot be cancelled
  Future<void> cancelDownload(String taskId);

  /// Gets all active downloads
  ///
  /// Returns list of [DownloadTask] that are currently downloading
  Future<List<DownloadTask>> getActiveDownloads();

  /// Gets all queued downloads
  ///
  /// Returns list of [DownloadTask] that are waiting to start
  Future<List<DownloadTask>> getQueuedDownloads();

  /// Gets all completed downloads
  ///
  /// Returns list of [DownloadTask] that have finished successfully
  Future<List<DownloadTask>> getCompletedDownloads();

  /// Gets all failed downloads
  ///
  /// Returns list of [DownloadTask] that have failed
  Future<List<DownloadTask>> getFailedDownloads();

  /// Gets download task by ID
  ///
  /// [taskId] - The ID of the download task
  /// Returns [DownloadTask] if found, null otherwise
  Future<DownloadTask?> getDownloadById(String taskId);

  /// Gets queue status including active, queued, and completed downloads
  ///
  /// Returns map with counts of different download states
  Future<Map<String, int>> getQueueStatus();

  /// Clears all completed downloads
  ///
  /// Removes all completed downloads from the queue
  Future<void> clearCompletedDownloads();

  /// Clears all failed downloads
  ///
  /// Removes all failed downloads from the queue
  Future<void> clearFailedDownloads();

  /// Reorders download queue
  ///
  /// [taskIds] - List of task IDs in new order
  /// Throws [Exception] if any task ID is invalid
  Future<void> reorderQueue(List<String> taskIds);

  /// Sets download priority
  ///
  /// [taskId] - The ID of the download task
  /// [priority] - New priority level (1 = highest, 5 = lowest)
  /// Throws [Exception] if task not found or priority invalid
  Future<void> setDownloadPriority(String taskId, int priority);

  /// Gets video information for download
  ///
  /// [videoUrl] - The YouTube video URL
  /// Returns [VideoInfo] with complete metadata
  /// Throws [Exception] if video cannot be analyzed
  Future<VideoInfo> getVideoInfo(String videoUrl);
}

@LazySingleton(as: DownloadDataSource)
class DownloadDataSourceImpl implements DownloadDataSource {
  final DownloadService _downloadService;
  final Map<String, DownloadTask> _downloadTasks = {};

  DownloadDataSourceImpl({required DownloadService downloadService})
    : _downloadService = downloadService;

  @override
  Future<DownloadTask> startDownload(StartDownloadParams params) async {
    try {
      developer.log(
        '[download_datasource.dart] - Starting download: ${params.url}',
      );

      // Create initial task first
      final initialTask = DownloadTask(
        id: _generateTaskId(),
        videoId: params.videoId,
        title: params.title,
        url: params.url,
        format: params.format,
        quality: params.quality,
        outputPath: params.outputPath,
        status: DownloadStatus.downloading,
        bytesDownloaded: 0,
        totalBytes: 0,
        progress: 0.0,
        createdAt: DateTime.now(),
        startedAt: DateTime.now(),
      );

      // Add task to map
      _downloadTasks[initialTask.id] = initialTask;

      // Start download in background
      _performDownloadInBackground(initialTask, params);

      // Return task immediately
      return initialTask;
    } catch (e) {
      developer.log(
        '[download_datasource.dart] - Failed to start download: $e',
      );
      throw Exception('Failed to start download: $e');
    }
  }

  void _performDownloadInBackground(
    DownloadTask task,
    StartDownloadParams params,
  ) async {
    try {
      // Use real download service
      final result = await _downloadService.startDownload(
        url: params.url,
        format: params.format,
        quality: params.quality,
        outputPath: params.outputPath,
        onProgress: (progress, speed, eta) {
          // Update task progress using task ID
          final currentTask = _downloadTasks[task.id];
          if (currentTask != null) {
            final updatedTask = currentTask.copyWith(
              progress: progress,
              bytesDownloaded: (currentTask.totalBytes * progress).round(),
            );
            _downloadTasks[task.id] = updatedTask;

            developer.log(
              '[download_datasource.dart] - Download progress: ${(progress * 100).toStringAsFixed(1)}% - $speed',
            );
          }
        },
      );

      result.when(
        success: (completedTask) {
          // Update task with final result
          _downloadTasks[task.id] = completedTask;
          developer.log(
            '[download_datasource.dart] - Download completed successfully',
          );
        },
        failure: (error) {
          // Mark task as failed
          final failedTask = task.copyWith(
            status: DownloadStatus.failed,
            errorMessage: error,
          );
          _downloadTasks[task.id] = failedTask;
          developer.log('[download_datasource.dart] - Download failed: $error');
        },
      );
    } catch (e) {
      // Mark task as failed
      final failedTask = task.copyWith(
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
      );
      _downloadTasks[task.id] = failedTask;
      developer.log('[download_datasource.dart] - Download error: $e');
    }
  }

  @override
  Future<DownloadTask> pauseDownload(String taskId) async {
    final task = _downloadTasks[taskId];
    if (task == null) {
      throw Exception('Download task not found');
    }

    final result = await _downloadService.pauseDownload(task);

    result.when(
      success: (pausedTask) {
        _downloadTasks[taskId] = pausedTask;
        return pausedTask;
      },
      failure: (error) {
        throw Exception('Failed to pause download: $error');
      },
    );

    return _downloadTasks[taskId]!;
  }

  @override
  Future<DownloadTask> resumeDownload(String taskId) async {
    final task = _downloadTasks[taskId];
    if (task == null) {
      throw Exception('Download task not found');
    }

    final result = await _downloadService.resumeDownload(task);

    result.when(
      success: (resumedTask) {
        _downloadTasks[taskId] = resumedTask;
        return resumedTask;
      },
      failure: (error) {
        throw Exception('Failed to resume download: $error');
      },
    );

    return _downloadTasks[taskId]!;
  }

  @override
  Future<void> cancelDownload(String taskId) async {
    final task = _downloadTasks[taskId];
    if (task == null) {
      throw Exception('Download task not found');
    }

    final result = await _downloadService.cancelDownload(task);

    result.when(
      success: (_) {
        _downloadTasks.remove(taskId);
      },
      failure: (error) {
        throw Exception('Failed to cancel download: $error');
      },
    );
  }

  @override
  Future<List<DownloadTask>> getActiveDownloads() async {
    return _downloadTasks.values
        .where((task) => task.status == DownloadStatus.downloading)
        .toList();
  }

  @override
  Future<List<DownloadTask>> getQueuedDownloads() async {
    return _downloadTasks.values
        .where((task) => task.status == DownloadStatus.queued)
        .toList();
  }

  @override
  Future<List<DownloadTask>> getCompletedDownloads() async {
    return _downloadTasks.values
        .where((task) => task.status == DownloadStatus.completed)
        .toList();
  }

  @override
  Future<List<DownloadTask>> getFailedDownloads() async {
    return _downloadTasks.values
        .where((task) => task.status == DownloadStatus.failed)
        .toList();
  }

  @override
  Future<DownloadTask?> getDownloadById(String taskId) async {
    return _downloadTasks[taskId];
  }

  @override
  Future<Map<String, int>> getQueueStatus() async {
    final active = await getActiveDownloads();
    final queued = await getQueuedDownloads();
    final completed = await getCompletedDownloads();
    final failed = await getFailedDownloads();

    return {
      'active': active.length,
      'queued': queued.length,
      'completed': completed.length,
      'failed': failed.length,
    };
  }

  @override
  Future<void> clearCompletedDownloads() async {
    final completedTasks = await getCompletedDownloads();
    for (final task in completedTasks) {
      _downloadTasks.remove(task.id);
    }
  }

  @override
  Future<void> clearFailedDownloads() async {
    final failedTasks = await getFailedDownloads();
    for (final task in failedTasks) {
      _downloadTasks.remove(task.id);
    }
  }

  @override
  Future<void> reorderQueue(List<String> taskIds) async {
    // Implementation for reordering queue
    // This would typically involve updating priority or order
  }

  @override
  Future<void> setDownloadPriority(String taskId, int priority) async {
    final task = _downloadTasks[taskId];
    if (task == null) {
      throw Exception('Download task not found');
    }
    // Implementation for setting priority
  }

  @override
  Future<VideoInfo> getVideoInfo(String videoUrl) async {
    // Implementation for getting video info
    // This would typically call YouTube service
    throw UnimplementedError('getVideoInfo not implemented');
  }

  String _generateTaskId() {
    return 'task_${DateTime.now().millisecondsSinceEpoch}';
  }
}
