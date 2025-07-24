import 'package:injectable/injectable.dart';
import '../../domain/entities/download_task.dart';
import '../../domain/repositories/download_repository.dart';

@LazySingleton(as: DownloadRepository)
class DownloadRepositoryImpl implements DownloadRepository {
  final List<DownloadTask> _downloads = [];

  @override
  Future<DownloadTask> startDownload(DownloadTask task) async {
    // Simulate starting download
    final updatedTask = task.copyWith(
      status: DownloadStatus.downloading,
      startedAt: DateTime.now(),
    );

    _downloads.add(updatedTask);
    return updatedTask;
  }

  @override
  Future<DownloadTask> pauseDownload(String taskId) async {
    final task = await getDownloadById(taskId);
    if (task == null) {
      throw Exception('Download task not found');
    }

    final updatedTask = task.copyWith(status: DownloadStatus.paused);
    _updateTask(updatedTask);
    return updatedTask;
  }

  @override
  Future<DownloadTask> resumeDownload(String taskId) async {
    final task = await getDownloadById(taskId);
    if (task == null) {
      throw Exception('Download task not found');
    }

    final updatedTask = task.copyWith(status: DownloadStatus.downloading);
    _updateTask(updatedTask);
    return updatedTask;
  }

  @override
  Future<DownloadTask> cancelDownload(String taskId) async {
    final task = await getDownloadById(taskId);
    if (task == null) {
      throw Exception('Download task not found');
    }

    final updatedTask = task.copyWith(status: DownloadStatus.cancelled);
    _updateTask(updatedTask);
    return updatedTask;
  }

  @override
  Future<List<DownloadTask>> getAllDownloads() async {
    return List.from(_downloads);
  }

  @override
  Future<DownloadTask?> getDownloadById(String taskId) async {
    try {
      return _downloads.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<DownloadTask>> getActiveDownloads() async {
    return _downloads
        .where(
          (task) =>
              task.status == DownloadStatus.downloading ||
              task.status == DownloadStatus.paused,
        )
        .toList();
  }

  @override
  Future<List<DownloadTask>> getCompletedDownloads() async {
    return _downloads
        .where((task) => task.status == DownloadStatus.completed)
        .toList();
  }

  @override
  Future<List<DownloadTask>> getFailedDownloads() async {
    return _downloads
        .where((task) => task.status == DownloadStatus.failed)
        .toList();
  }

  @override
  Future<DownloadTask> updateProgress(
    String taskId,
    int bytesDownloaded,
    int totalBytes,
  ) async {
    final task = await getDownloadById(taskId);
    if (task == null) {
      throw Exception('Download task not found');
    }

    final updatedTask = task.updateProgress(bytesDownloaded, totalBytes);
    _updateTask(updatedTask);
    return updatedTask;
  }

  @override
  Future<DownloadTask> retryDownload(String taskId) async {
    final task = await getDownloadById(taskId);
    if (task == null) {
      throw Exception('Download task not found');
    }

    final updatedTask = task
        .copyWith(status: DownloadStatus.downloading, errorMessage: null)
        .incrementRetryCount();

    _updateTask(updatedTask);
    return updatedTask;
  }

  @override
  Future<int> clearCompletedDownloads() async {
    final completedCount = _downloads
        .where((task) => task.status == DownloadStatus.completed)
        .length;

    _downloads.removeWhere((task) => task.status == DownloadStatus.completed);

    return completedCount;
  }

  @override
  Future<int> clearFailedDownloads() async {
    final failedCount = _downloads
        .where((task) => task.status == DownloadStatus.failed)
        .length;

    _downloads.removeWhere((task) => task.status == DownloadStatus.failed);

    return failedCount;
  }

  @override
  Future<Map<String, dynamic>> getQueueStatus() async {
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

    return {
      'total': total,
      'active': active,
      'pending': pending,
      'completed': completed,
      'failed': failed,
    };
  }

  @override
  Future<void> reorderQueue(List<String> taskIds) async {
    // Implementation for queue reordering
    // This is a simplified implementation
    final reorderedTasks = <DownloadTask>[];

    for (final taskId in taskIds) {
      final task = await getDownloadById(taskId);
      if (task != null) {
        reorderedTasks.add(task);
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
  }

  @override
  Future<void> setPriority(String taskId, int priority) async {
    // Implementation for setting priority
    // This is a simplified implementation
    // In a real implementation, you would store priority in the task
  }

  void _updateTask(DownloadTask updatedTask) {
    final index = _downloads.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _downloads[index] = updatedTask;
    }
  }
}
