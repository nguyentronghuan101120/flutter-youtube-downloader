import 'package:injectable/injectable.dart';
import '../../domain/entities/download_task.dart';
import '../../core/constants/download_status.dart';
import '../../core/utils/download_task_utils.dart';
import '../../domain/repositories/download_repository.dart';
import '../../core/result/result.dart';
import '../datasources/download_datasource.dart';

@LazySingleton(as: DownloadRepository)
class DownloadRepositoryImpl implements DownloadRepository {
  final DownloadDataSource _downloadDataSource;
  final List<DownloadTask> _downloads = [];

  DownloadRepositoryImpl({required DownloadDataSource downloadDataSource})
    : _downloadDataSource = downloadDataSource;

  @override
  Future<Result<DownloadTask>> startDownload(
    DownloadTask task, {
    Function(double progress, int bytesDownloaded, int totalBytes)? onProgress,
  }) async {
    try {
      // Update task status to downloading
      final updatedTask = task.copyWith(
        status: DownloadStatus.downloading,
        startedAt: DateTime.now(),
      );

      _downloads.add(updatedTask);

      // Start actual download using data source
      await _downloadDataSource.startDownload(
        updatedTask,
        onProgress: (progress, bytesDownloaded, totalBytes) {
          // Update task progress
          final progressTask = DownloadTaskUtils.updateProgress(
            updatedTask,
            bytesDownloaded,
            totalBytes,
          );
          _updateTask(progressTask);

          // Call progress callback
          onProgress?.call(progress, bytesDownloaded, totalBytes);
        },
      );

      // Mark as completed
      final completedTask = updatedTask.copyWith(
        status: DownloadStatus.completed,
        completedAt: DateTime.now(),
      );
      _updateTask(completedTask);

      return Result.success(completedTask);
    } catch (e) {
      // Mark as failed
      final failedTask = task.copyWith(
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
        completedAt: DateTime.now(),
      );
      _updateTask(failedTask);
      return Result.failure('Download failed: $e');
    }
  }

  @override
  Future<Result<DownloadTask>> pauseDownload(String taskId) async {
    try {
      final taskResult = await getDownloadById(taskId);
      if (taskResult.isFailure) {
        return Result.failure('Download task not found');
      }

      final task = taskResult.data;
      if (task == null) {
        return Result.failure('Download task not found');
      }

      if (task.status != DownloadStatus.downloading) {
        return Result.failure('Cannot pause task that is not downloading');
      }

      // Pause download in data source
      await _downloadDataSource.pauseDownload(taskId);

      final updatedTask = task.copyWith(
        status: DownloadStatus.paused,
        pausedAt: DateTime.now(),
      );
      _updateTask(updatedTask);
      return Result.success(updatedTask);
    } catch (e) {
      return Result.failure('Failed to pause download: $e');
    }
  }

  @override
  Future<Result<DownloadTask>> resumeDownload(
    String taskId, {
    Function(double progress, int bytesDownloaded, int totalBytes)? onProgress,
  }) async {
    try {
      final taskResult = await getDownloadById(taskId);
      if (taskResult.isFailure) {
        return Result.failure('Download task not found');
      }

      final task = taskResult.data;
      if (task == null) {
        return Result.failure('Download task not found');
      }

      if (task.status != DownloadStatus.paused) {
        return Result.failure('Cannot resume task that is not paused');
      }

      // Resume download in data source
      await _downloadDataSource.resumeDownload(
        taskId,
        onProgress: (progress, bytesDownloaded, totalBytes) {
          // Update task progress
          final progressTask = DownloadTaskUtils.updateProgress(
            task,
            bytesDownloaded,
            totalBytes,
          );
          _updateTask(progressTask);

          // Call progress callback
          onProgress?.call(progress, bytesDownloaded, totalBytes);
        },
      );

      final updatedTask = task.copyWith(
        status: DownloadStatus.downloading,
        pausedAt: null,
      );
      _updateTask(updatedTask);
      return Result.success(updatedTask);
    } catch (e) {
      return Result.failure('Failed to resume download: $e');
    }
  }

  @override
  Future<Result<DownloadTask>> cancelDownload(String taskId) async {
    try {
      final taskResult = await getDownloadById(taskId);
      if (taskResult.isFailure) {
        return Result.failure('Download task not found');
      }

      final task = taskResult.data;
      if (task == null) {
        return Result.failure('Download task not found');
      }

      // Cancel download in data source
      await _downloadDataSource.cancelDownload(taskId);

      final updatedTask = task.copyWith(
        status: DownloadStatus.cancelled,
        cancelledAt: DateTime.now(),
      );
      _updateTask(updatedTask);
      return Result.success(updatedTask);
    } catch (e) {
      return Result.failure('Failed to cancel download: $e');
    }
  }

  @override
  Future<Result<List<DownloadTask>>> getAllDownloads() async {
    try {
      return Result.success(List.from(_downloads));
    } catch (e) {
      return Result.failure('Failed to get downloads: $e');
    }
  }

  @override
  Future<Result<DownloadTask?>> getDownloadById(String taskId) async {
    try {
      final task = _downloads.firstWhere((task) => task.id == taskId);
      return Result.success(task);
    } catch (e) {
      return Result.success(null);
    }
  }

  @override
  Future<Result<List<DownloadTask>>> getActiveDownloads() async {
    try {
      final activeDownloads = _downloads
          .where(
            (task) =>
                task.status == DownloadStatus.downloading ||
                task.status == DownloadStatus.paused,
          )
          .toList();
      return Result.success(activeDownloads);
    } catch (e) {
      return Result.failure('Failed to get active downloads: $e');
    }
  }

  @override
  Future<Result<List<DownloadTask>>> getCompletedDownloads() async {
    try {
      final completedDownloads = _downloads
          .where((task) => task.status == DownloadStatus.completed)
          .toList();
      return Result.success(completedDownloads);
    } catch (e) {
      return Result.failure('Failed to get completed downloads: $e');
    }
  }

  @override
  Future<Result<List<DownloadTask>>> getFailedDownloads() async {
    try {
      final failedDownloads = _downloads
          .where((task) => task.status == DownloadStatus.failed)
          .toList();
      return Result.success(failedDownloads);
    } catch (e) {
      return Result.failure('Failed to get failed downloads: $e');
    }
  }

  @override
  Future<Result<DownloadTask>> updateProgress(
    String taskId,
    int bytesDownloaded,
    int totalBytes,
  ) async {
    try {
      final taskResult = await getDownloadById(taskId);
      if (taskResult.isFailure) {
        return Result.failure('Download task not found');
      }

      final task = taskResult.data;
      if (task == null) {
        return Result.failure('Download task not found');
      }

      final updatedTask = DownloadTaskUtils.updateProgress(
        task,
        bytesDownloaded,
        totalBytes,
      );
      _updateTask(updatedTask);
      return Result.success(updatedTask);
    } catch (e) {
      return Result.failure('Failed to update progress: $e');
    }
  }

  @override
  Future<Result<DownloadTask>> retryDownload(String taskId) async {
    try {
      final taskResult = await getDownloadById(taskId);
      if (taskResult.isFailure) {
        return Result.failure('Download task not found');
      }

      final task = taskResult.data;
      if (task == null) {
        return Result.failure('Download task not found');
      }

      if (task.status != DownloadStatus.failed) {
        return Result.failure('Cannot retry task that is not failed');
      }

      final updatedTask = DownloadTaskUtils.incrementRetryCount(
        task.copyWith(
          status: DownloadStatus.downloading,
          errorMessage: null,
          startedAt: DateTime.now(),
        ),
      );

      _updateTask(updatedTask);

      // Retry download
      return await startDownload(updatedTask);
    } catch (e) {
      return Result.failure('Failed to retry download: $e');
    }
  }

  @override
  Future<Result<int>> clearCompletedDownloads() async {
    try {
      final completedCount = _downloads
          .where((task) => task.status == DownloadStatus.completed)
          .length;

      _downloads.removeWhere((task) => task.status == DownloadStatus.completed);

      return Result.success(completedCount);
    } catch (e) {
      return Result.failure('Failed to clear completed downloads: $e');
    }
  }

  @override
  Future<Result<int>> clearFailedDownloads() async {
    try {
      final failedCount = _downloads
          .where((task) => task.status == DownloadStatus.failed)
          .length;

      _downloads.removeWhere((task) => task.status == DownloadStatus.failed);

      return Result.success(failedCount);
    } catch (e) {
      return Result.failure('Failed to clear failed downloads: $e');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getQueueStatus() async {
    try {
      final total = _downloads.length;
      final active = _downloads
          .where((task) => task.status == DownloadStatus.downloading)
          .length;
      final pending = _downloads
          .where((task) => task.status == DownloadStatus.pending)
          .length;
      final completed = _downloads
          .where((task) => task.status == DownloadStatus.completed)
          .length;
      final failed = _downloads
          .where((task) => task.status == DownloadStatus.failed)
          .length;
      final paused = _downloads
          .where((task) => task.status == DownloadStatus.paused)
          .length;
      final cancelled = _downloads
          .where((task) => task.status == DownloadStatus.cancelled)
          .length;

      final status = {
        'total': total,
        'active': active,
        'pending': pending,
        'completed': completed,
        'failed': failed,
        'paused': paused,
        'cancelled': cancelled,
      };

      return Result.success(status);
    } catch (e) {
      return Result.failure('Failed to get queue status: $e');
    }
  }

  @override
  Future<Result<void>> reorderQueue(List<String> taskIds) async {
    try {
      final reorderedTasks = <DownloadTask>[];

      for (final taskId in taskIds) {
        final taskResult = await getDownloadById(taskId);
        if (taskResult.isSuccess && taskResult.data != null) {
          reorderedTasks.add(taskResult.data!);
        }
      }

      // Add remaining tasks that weren't in the reorder list
      for (final task in _downloads) {
        if (!taskIds.contains(task.id)) {
          reorderedTasks.add(task);
        }
      }

      _downloads.clear();
      _downloads.addAll(reorderedTasks);

      return const Result.success(null);
    } catch (e) {
      return Result.failure('Failed to reorder queue: $e');
    }
  }

  @override
  Future<Result<void>> setPriority(String taskId, int priority) async {
    try {
      final taskResult = await getDownloadById(taskId);
      if (taskResult.isFailure) {
        return Result.failure('Download task not found');
      }

      final task = taskResult.data;
      if (task == null) {
        return Result.failure('Download task not found');
      }

      if (priority < 1 || priority > 5) {
        return Result.failure('Priority must be between 1 and 5');
      }

      final updatedTask = task.copyWith(priority: priority);
      _updateTask(updatedTask);

      return const Result.success(null);
    } catch (e) {
      return Result.failure('Failed to set priority: $e');
    }
  }

  void _updateTask(DownloadTask updatedTask) {
    final index = _downloads.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _downloads[index] = updatedTask;
    }
  }
}
