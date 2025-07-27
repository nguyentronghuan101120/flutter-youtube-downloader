import '../entities/download_task.dart';
import '../entities/download_progress.dart';
import '../../core/result/result.dart';

abstract class DownloadRepository {
  /// Starts a new download task
  ///
  /// [params] - The download parameters
  /// Returns the created download task
  /// Throws [Exception] if download fails to start
  Future<Result<DownloadTask>> startDownload(StartDownloadParams params);

  /// Pauses an active download task
  ///
  /// [taskId] - The ID of the task to pause
  /// Returns the updated task with paused status
  /// Throws [Exception] if task not found or cannot be paused
  Future<Result<DownloadTask>> pauseDownload(String taskId);

  /// Resumes a paused download task
  ///
  /// [taskId] - The ID of the task to resume
  /// Returns the updated task with downloading status
  /// Throws [Exception] if task not found or cannot be resumed
  Future<Result<DownloadTask>> resumeDownload(String taskId);

  /// Cancels a download task
  ///
  /// [taskId] - The ID of the task to cancel
  /// Throws [Exception] if task not found
  Future<Result<void>> cancelDownload(String taskId);

  /// Gets all download tasks
  ///
  /// Returns list of all download tasks
  Future<Result<List<DownloadTask>>> getAllDownloads();

  /// Gets a specific download task by ID
  ///
  /// [taskId] - The ID of the task to retrieve
  /// Returns the download task if found
  /// Throws [Exception] if task not found
  Future<Result<DownloadTask>> getDownloadById(String taskId);

  /// Gets active download tasks (downloading)
  ///
  /// Returns list of active download tasks
  Future<Result<List<DownloadTask>>> getActiveDownloads();

  /// Gets queued download tasks
  ///
  /// Returns list of queued download tasks
  Future<Result<List<DownloadTask>>> getQueuedDownloads();

  /// Gets completed download tasks
  ///
  /// Returns list of completed download tasks
  Future<Result<List<DownloadTask>>> getCompletedDownloads();

  /// Gets failed download tasks
  ///
  /// Returns list of failed download tasks
  Future<Result<List<DownloadTask>>> getFailedDownloads();

  /// Gets download queue status
  ///
  /// Returns information about current queue state
  Future<Result<QueueStatus>> getQueueStatus();

  /// Clears completed downloads
  ///
  /// Removes all completed download tasks from storage
  Future<Result<void>> clearCompletedDownloads();

  /// Clears failed downloads
  ///
  /// Removes all failed download tasks from storage
  Future<Result<void>> clearFailedDownloads();

  /// Sets download priority
  ///
  /// [taskId] - The ID of the task
  /// [priority] - Priority level (1 = highest, 5 = lowest)
  /// Throws [Exception] if task not found
  Future<Result<void>> setDownloadPriority(String taskId, int priority);

  /// Reorders download queue
  ///
  /// [taskIds] - List of task IDs in new order
  /// Throws [Exception] if any task ID is invalid
  Future<Result<void>> reorderDownloadQueue(List<String> taskIds);

  /// Gets real-time download progress stream
  ///
  /// [taskId] - The ID of the task to monitor
  /// Returns a stream of download progress updates
  Stream<DownloadProgress> getDownloadProgressStream(String taskId);

  /// Checks if file is in system Downloads folder
  ///
  /// [filePath] - The file path to check
  /// Returns true if file is in system Downloads folder
  bool isInSystemDownloads(String filePath);

  /// Opens a file using system default application
  ///
  /// [filePath] - The file path to open
  /// Returns true if file was opened successfully
  Future<bool> openFile(String filePath);

  /// Moves a file to system Downloads folder (macOS only)
  ///
  /// [filePath] - The file path to move
  /// Returns the new path if successful, null if failed
  Future<String?> moveToSystemDownloads(String filePath);
}

class StartDownloadParams {
  final String videoId;
  final String title;
  final String url;
  final String format;
  final String quality;
  final String outputPath;

  StartDownloadParams({
    required this.videoId,
    required this.title,
    required this.url,
    required this.format,
    required this.quality,
    required this.outputPath,
  });
}

class QueueStatus {
  final int activeDownloads;
  final int queuedDownloads;
  final int completedDownloads;
  final int failedDownloads;
  final int totalDownloads;

  QueueStatus({
    required this.activeDownloads,
    required this.queuedDownloads,
    required this.completedDownloads,
    required this.failedDownloads,
    required this.totalDownloads,
  });
}
