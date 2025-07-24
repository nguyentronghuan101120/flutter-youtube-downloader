import '../entities/download_task.dart';
import '../../core/result/result.dart';

abstract class DownloadRepository {
  /// Starts a new download task
  ///
  /// [task] - The download task to start
  /// [onProgress] - Optional progress callback
  /// Returns the updated task with status
  /// Throws [Exception] if download fails to start
  Future<Result<DownloadTask>> startDownload(
    DownloadTask task, {
    Function(double progress, int bytesDownloaded, int totalBytes)? onProgress,
  });

  /// Pauses an active download task
  ///
  /// [taskId] - The ID of the task to pause
  /// Returns the updated task with paused status
  /// Throws [Exception] if task not found or cannot be paused
  Future<Result<DownloadTask>> pauseDownload(String taskId);

  /// Resumes a paused download task
  ///
  /// [taskId] - The ID of the task to resume
  /// [onProgress] - Optional progress callback
  /// Returns the updated task with downloading status
  /// Throws [Exception] if task not found or cannot be resumed
  Future<Result<DownloadTask>> resumeDownload(
    String taskId, {
    Function(double progress, int bytesDownloaded, int totalBytes)? onProgress,
  });

  /// Cancels a download task
  ///
  /// [taskId] - The ID of the task to cancel
  /// Returns the updated task with cancelled status
  /// Throws [Exception] if task not found
  Future<Result<DownloadTask>> cancelDownload(String taskId);

  /// Gets all download tasks
  ///
  /// Returns list of all download tasks
  Future<Result<List<DownloadTask>>> getAllDownloads();

  /// Gets a specific download task by ID
  ///
  /// [taskId] - The ID of the task to retrieve
  /// Returns the download task if found, null otherwise
  Future<Result<DownloadTask?>> getDownloadById(String taskId);

  /// Gets active download tasks (downloading or paused)
  ///
  /// Returns list of active download tasks
  Future<Result<List<DownloadTask>>> getActiveDownloads();

  /// Gets completed download tasks
  ///
  /// Returns list of completed download tasks
  Future<Result<List<DownloadTask>>> getCompletedDownloads();

  /// Gets failed download tasks
  ///
  /// Returns list of failed download tasks
  Future<Result<List<DownloadTask>>> getFailedDownloads();

  /// Updates download progress
  ///
  /// [taskId] - The ID of the task to update
  /// [bytesDownloaded] - Number of bytes downloaded
  /// [totalBytes] - Total number of bytes
  /// Returns the updated task with new progress
  /// Throws [Exception] if task not found
  Future<Result<DownloadTask>> updateProgress(
    String taskId,
    int bytesDownloaded,
    int totalBytes,
  );

  /// Retries a failed download task
  ///
  /// [taskId] - The ID of the task to retry
  /// Returns the updated task with retry status
  /// Throws [Exception] if task not found or cannot be retried
  Future<Result<DownloadTask>> retryDownload(String taskId);

  /// Clears completed downloads
  ///
  /// Removes all completed download tasks from storage
  /// Returns number of tasks cleared
  Future<Result<int>> clearCompletedDownloads();

  /// Clears failed downloads
  ///
  /// Removes all failed download tasks from storage
  /// Returns number of tasks cleared
  Future<Result<int>> clearFailedDownloads();

  /// Gets download queue status
  ///
  /// Returns information about current queue state
  Future<Result<Map<String, dynamic>>> getQueueStatus();

  /// Reorders download queue
  ///
  /// [taskIds] - List of task IDs in new order
  /// Throws [Exception] if any task ID is invalid
  Future<Result<void>> reorderQueue(List<String> taskIds);

  /// Sets download priority
  ///
  /// [taskId] - The ID of the task
  /// [priority] - Priority level (1 = highest, 5 = lowest)
  /// Throws [Exception] if task not found
  Future<Result<void>> setPriority(String taskId, int priority);
}
