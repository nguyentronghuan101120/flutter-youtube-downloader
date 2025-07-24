import 'package:injectable/injectable.dart';
import '../../domain/entities/download_task.dart';
import '../../domain/repositories/download_repository.dart';
import '../../core/result/result.dart';
import '../datasources/download_datasource.dart';

@LazySingleton(as: DownloadRepository)
class DownloadRepositoryImpl implements DownloadRepository {
  final DownloadDataSource _dataSource;

  DownloadRepositoryImpl({required DownloadDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<Result<DownloadTask>> startDownload(StartDownloadParams params) async {
    try {
      final task = await _dataSource.startDownload(params);
      return Result.success(task);
    } catch (e) {
      return Result.failure('Failed to start download: $e');
    }
  }

  @override
  Future<Result<DownloadTask>> pauseDownload(String taskId) async {
    try {
      final task = await _dataSource.pauseDownload(taskId);
      return Result.success(task);
    } catch (e) {
      return Result.failure('Failed to pause download: $e');
    }
  }

  @override
  Future<Result<DownloadTask>> resumeDownload(String taskId) async {
    try {
      final task = await _dataSource.resumeDownload(taskId);
      return Result.success(task);
    } catch (e) {
      return Result.failure('Failed to resume download: $e');
    }
  }

  @override
  Future<Result<void>> cancelDownload(String taskId) async {
    try {
      await _dataSource.cancelDownload(taskId);
      return const Result.success(null);
    } catch (e) {
      return Result.failure('Failed to cancel download: $e');
    }
  }

  @override
  Future<Result<DownloadTask>> getDownloadById(String taskId) async {
    try {
      final task = await _dataSource.getDownloadById(taskId);
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
      final activeDownloads = await _dataSource.getActiveDownloads();
      final queuedDownloads = await _dataSource.getQueuedDownloads();
      final completedDownloads = await _dataSource.getCompletedDownloads();
      final failedDownloads = await _dataSource.getFailedDownloads();

      final allDownloads = [
        ...activeDownloads,
        ...queuedDownloads,
        ...completedDownloads,
        ...failedDownloads,
      ];

      return Result.success(allDownloads);
    } catch (e) {
      return Result.failure('Failed to get all downloads: $e');
    }
  }

  @override
  Future<Result<List<DownloadTask>>> getActiveDownloads() async {
    try {
      final downloads = await _dataSource.getActiveDownloads();
      return Result.success(downloads);
    } catch (e) {
      return Result.failure('Failed to get active downloads: $e');
    }
  }

  @override
  Future<Result<List<DownloadTask>>> getQueuedDownloads() async {
    try {
      final downloads = await _dataSource.getQueuedDownloads();
      return Result.success(downloads);
    } catch (e) {
      return Result.failure('Failed to get queued downloads: $e');
    }
  }

  @override
  Future<Result<List<DownloadTask>>> getCompletedDownloads() async {
    try {
      final downloads = await _dataSource.getCompletedDownloads();
      return Result.success(downloads);
    } catch (e) {
      return Result.failure('Failed to get completed downloads: $e');
    }
  }

  @override
  Future<Result<List<DownloadTask>>> getFailedDownloads() async {
    try {
      final downloads = await _dataSource.getFailedDownloads();
      return Result.success(downloads);
    } catch (e) {
      return Result.failure('Failed to get failed downloads: $e');
    }
  }

  @override
  Future<Result<QueueStatus>> getQueueStatus() async {
    try {
      final statusMap = await _dataSource.getQueueStatus();

      final active = statusMap['active'] ?? 0;
      final queued = statusMap['queued'] ?? 0;
      final completed = statusMap['completed'] ?? 0;
      final failed = statusMap['failed'] ?? 0;
      final total = active + queued + completed + failed;

      final status = QueueStatus(
        activeDownloads: active,
        queuedDownloads: queued,
        completedDownloads: completed,
        failedDownloads: failed,
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
      await _dataSource.clearCompletedDownloads();
      return const Result.success(null);
    } catch (e) {
      return Result.failure('Failed to clear completed downloads: $e');
    }
  }

  @override
  Future<Result<void>> clearFailedDownloads() async {
    try {
      await _dataSource.clearFailedDownloads();
      return const Result.success(null);
    } catch (e) {
      return Result.failure('Failed to clear failed downloads: $e');
    }
  }

  @override
  Future<Result<void>> setDownloadPriority(String taskId, int priority) async {
    try {
      await _dataSource.setDownloadPriority(taskId, priority);
      return const Result.success(null);
    } catch (e) {
      return Result.failure('Failed to set download priority: $e');
    }
  }

  @override
  Future<Result<void>> reorderDownloadQueue(List<String> taskIds) async {
    try {
      await _dataSource.reorderQueue(taskIds);
      return const Result.success(null);
    } catch (e) {
      return Result.failure('Failed to reorder download queue: $e');
    }
  }
}
