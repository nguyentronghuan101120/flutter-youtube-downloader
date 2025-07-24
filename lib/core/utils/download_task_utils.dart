import '../../domain/entities/download_task.dart';
import '../constants/download_status.dart';

/// Utility class for DownloadTask operations
class DownloadTaskUtils {
  /// Updates progress based on bytes downloaded
  static DownloadTask updateProgress(
    DownloadTask task,
    int bytesDownloaded,
    int totalBytes,
  ) {
    final progress = totalBytes > 0 ? bytesDownloaded / totalBytes : 0.0;
    return task.copyWith(
      bytesDownloaded: bytesDownloaded,
      totalBytes: totalBytes,
      progress: progress,
    );
  }

  /// Updates status and related timestamps
  static DownloadTask updateStatus(
    DownloadTask task,
    DownloadStatus newStatus,
  ) {
    DateTime? startedAt = task.startedAt;
    DateTime? completedAt = task.completedAt;

    switch (newStatus) {
      case DownloadStatus.downloading:
        startedAt = startedAt ?? DateTime.now();
        break;
      case DownloadStatus.completed:
        completedAt = DateTime.now();
        break;
      default:
        break;
    }

    return task.copyWith(
      status: newStatus,
      startedAt: startedAt,
      completedAt: completedAt,
    );
  }

  /// Increments retry count
  static DownloadTask incrementRetryCount(DownloadTask task) {
    return task.copyWith(retryCount: task.retryCount + 1);
  }

  /// Sets error message
  static DownloadTask setError(DownloadTask task, String errorMessage) {
    return task.copyWith(
      status: DownloadStatus.failed,
      errorMessage: errorMessage,
    );
  }

  /// Checks if download is in progress
  static bool isInProgress(DownloadTask task) =>
      task.status == DownloadStatus.downloading;

  /// Checks if download is completed
  static bool isCompleted(DownloadTask task) =>
      task.status == DownloadStatus.completed;

  /// Checks if download failed
  static bool isFailed(DownloadTask task) =>
      task.status == DownloadStatus.failed;

  /// Checks if download can be resumed
  static bool canResume(DownloadTask task) =>
      task.isResumable &&
      (task.status == DownloadStatus.paused ||
          task.status == DownloadStatus.failed);

  /// Gets formatted file size
  static String getFormattedFileSize(DownloadTask task) {
    if (task.totalBytes == 0) return 'Unknown size';

    const units = ['B', 'KB', 'MB', 'GB'];
    double size = task.totalBytes.toDouble();
    int unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  /// Gets formatted downloaded size
  static String getFormattedDownloadedSize(DownloadTask task) {
    if (task.bytesDownloaded == 0) return '0 B';

    const units = ['B', 'KB', 'MB', 'GB'];
    double size = task.bytesDownloaded.toDouble();
    int unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }
}
