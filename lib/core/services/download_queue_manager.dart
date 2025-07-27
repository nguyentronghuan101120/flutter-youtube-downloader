import 'dart:async';
import 'dart:developer' as developer;
import '../../domain/entities/download_task.dart';
import '../constants/download_status.dart';
import '../constants/app_constants.dart';

class DownloadQueueManager {
  final Map<String, DownloadTask> _downloadTasks = {};
  final Function(DownloadTask) _onStartDownload;

  DownloadQueueManager(this._onStartDownload);

  /// Add task to queue and process
  Future<void> addToQueue(DownloadTask task) async {
    _downloadTasks[task.id] = task;
    await _processQueue();
  }

  /// Process the download queue
  Future<void> _processQueue() async {
    final queuedTasks = _downloadTasks.values
        .where((task) => task.status == DownloadStatus.queued)
        .toList();

    // Sort by creation time to maintain order
    queuedTasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    for (final task in queuedTasks) {
      final activeDownloads = _downloadTasks.values
          .where((t) => t.status == DownloadStatus.downloading)
          .length;

      if (activeDownloads < AppConstants.maxConcurrentDownloads) {
        await _startDownloadFromQueue(task);
      } else {
        break;
      }
    }
  }

  /// Start download from queue
  Future<void> _startDownloadFromQueue(DownloadTask queuedTask) async {
    try {
      final currentTask = _downloadTasks[queuedTask.id];
      if (currentTask == null || currentTask.status != DownloadStatus.queued) {
        developer.log(
          '[download_queue_manager.dart] - Task ${queuedTask.id} is no longer queued, skipping',
        );
        return;
      }

      final downloadingTask = queuedTask.copyWith(
        status: DownloadStatus.downloading,
        startedAt: DateTime.now(),
      );
      _downloadTasks[queuedTask.id] = downloadingTask;

      developer.log(
        '[download_queue_manager.dart] - Starting download from queue: ${queuedTask.title} (ID: ${queuedTask.id})',
      );

      _onStartDownload(downloadingTask);
    } catch (e) {
      developer.log(
        '[download_queue_manager.dart] - Failed to start download from queue: $e',
      );
      final failedTask = queuedTask.copyWith(
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
      );
      _downloadTasks[queuedTask.id] = failedTask;
    }
  }

  /// Update task status
  void updateTask(DownloadTask task) {
    _downloadTasks[task.id] = task;
  }

  /// Get task by ID
  DownloadTask? getTask(String taskId) {
    return _downloadTasks[taskId];
  }

  /// Get all tasks
  Map<String, DownloadTask> getAllTasks() {
    return Map.unmodifiable(_downloadTasks);
  }

  /// Remove task
  void removeTask(String taskId) {
    _downloadTasks.remove(taskId);
  }

  /// Get tasks by status
  List<DownloadTask> getTasksByStatus(DownloadStatus status) {
    return _downloadTasks.values
        .where((task) => task.status == status)
        .toList();
  }

  /// Process queue after task completion
  void onTaskCompleted(String taskId) {
    _processQueue();
  }

  /// Generate unique task ID
  String generateTaskId() {
    return 'task_${DateTime.now().millisecondsSinceEpoch}';
  }
}
