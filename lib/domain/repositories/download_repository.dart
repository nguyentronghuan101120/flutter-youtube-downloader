import '../entities/download_task.dart';

abstract class DownloadRepository {
  /// Starts a new download task
  ///
  /// [task] - The download task to start
  /// Returns the updated task with status
  /// Throws [Exception] if download fails to start
  Future<DownloadTask> startDownload(DownloadTask task);

  /// Pauses an active download task
  ///
  /// [taskId] - The ID of the task to pause
  /// Returns the updated task with paused status
  /// Throws [Exception] if task not found or cannot be paused
  Future<DownloadTask> pauseDownload(String taskId);

  /// Resumes a paused download task
  ///
  /// [taskId] - The ID of the task to resume
  /// Returns the updated task with downloading status
  /// Throws [Exception] if task not found or cannot be resumed
  Future<DownloadTask> resumeDownload(String taskId);

  /// Cancels a download task
  ///
  /// [taskId] - The ID of the task to cancel
  /// Returns the updated task with cancelled status
  /// Throws [Exception] if task not found
  Future<DownloadTask> cancelDownload(String taskId);

  /// Gets all download tasks
  ///
  /// Returns list of all download tasks
  Future<List<DownloadTask>> getAllDownloads();

  /// Gets a specific download task by ID
  ///
  /// [taskId] - The ID of the task to retrieve
  /// Returns the download task if found, null otherwise
  Future<DownloadTask?> getDownloadById(String taskId);

  /// Gets active download tasks (downloading or paused)
  ///
  /// Returns list of active download tasks
  Future<List<DownloadTask>> getActiveDownloads();

  /// Gets completed download tasks
  ///
  /// Returns list of completed download tasks
  Future<List<DownloadTask>> getCompletedDownloads();

  /// Gets failed download tasks
  ///
  /// Returns list of failed download tasks
  Future<List<DownloadTask>> getFailedDownloads();

  /// Updates download progress
  ///
  /// [taskId] - The ID of the task to update
  /// [bytesDownloaded] - Number of bytes downloaded
  /// [totalBytes] - Total number of bytes
  /// Returns the updated task with new progress
  /// Throws [Exception] if task not found
  Future<DownloadTask> updateProgress(
    String taskId,
    int bytesDownloaded,
    int totalBytes,
  );

  /// Retries a failed download task
  ///
  /// [taskId] - The ID of the task to retry
  /// Returns the updated task with retry status
  /// Throws [Exception] if task not found or cannot be retried
  Future<DownloadTask> retryDownload(String taskId);

  /// Clears completed downloads
  ///
  /// Removes all completed download tasks from storage
  /// Returns number of tasks cleared
  Future<int> clearCompletedDownloads();

  /// Clears failed downloads
  ///
  /// Removes all failed download tasks from storage
  /// Returns number of tasks cleared
  Future<int> clearFailedDownloads();

  /// Gets download queue status
  ///
  /// Returns information about current queue state
  Future<Map<String, dynamic>> getQueueStatus();

  /// Reorders download queue
  ///
  /// [taskIds] - List of task IDs in new order
  /// Throws [Exception] if any task ID is invalid
  Future<void> reorderQueue(List<String> taskIds);

  /// Sets download priority
  ///
  /// [taskId] - The ID of the task
  /// [priority] - Priority level (1 = highest, 5 = lowest)
  /// Throws [Exception] if task not found
  Future<void> setPriority(String taskId, int priority);
}
