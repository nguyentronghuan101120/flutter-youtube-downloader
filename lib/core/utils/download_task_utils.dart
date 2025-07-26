import '../../domain/entities/download_task.dart';
import '../constants/download_status.dart';
import 'file_utils.dart';

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
      task.status == DownloadStatus.paused;

  /// Calculate download speed - unified method for all speed calculations
  static String calculateSpeed(int bytesDownloaded, DateTime startTime) {
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    if (elapsed == 0) return '0 KB/s';

    final bytesPerSecond = bytesDownloaded / elapsed;
    return '${FileUtils.formatFileSize(bytesPerSecond.round())}/s';
  }

  /// Calculate ETA - unified method for all ETA calculations
  static String calculateEta(
    int bytesDownloaded,
    int totalBytes,
    String speed,
  ) {
    if (bytesDownloaded <= 0 || totalBytes <= 0) return 'Calculating...';

    final remainingBytes = totalBytes - bytesDownloaded;

    // Extract speed value from string (e.g., "1.5 MB/s" -> 1.5)
    final speedMatch = RegExp(r'(\d+\.?\d*)').firstMatch(speed);
    if (speedMatch == null) return 'Calculating...';

    final speedValue = double.tryParse(speedMatch.group(1) ?? '0') ?? 0;
    if (speedValue <= 0) return 'Calculating...';

    // Convert speed to bytes per second
    double bytesPerSecond;
    if (speed.contains('MB/s')) {
      bytesPerSecond = speedValue * 1024 * 1024;
    } else if (speed.contains('KB/s')) {
      bytesPerSecond = speedValue * 1024;
    } else if (speed.contains('B/s')) {
      bytesPerSecond = speedValue;
    } else {
      bytesPerSecond = speedValue;
    }

    if (bytesPerSecond <= 0) return 'Calculating...';

    final remainingSeconds = remainingBytes / bytesPerSecond;

    if (remainingSeconds < 60) {
      return '${remainingSeconds.round()}s';
    } else if (remainingSeconds < 3600) {
      return '${(remainingSeconds / 60).round()}m';
    } else {
      return '${(remainingSeconds / 3600).round()}h';
    }
  }

  /// Calculate progress percentage
  static double calculateProgressPercentage(DownloadTask task) {
    return (task.progress * 100).clamp(0.0, 100.0);
  }

  /// Get formatted progress string
  static String getProgressString(DownloadTask task) {
    return '${calculateProgressPercentage(task).toStringAsFixed(1)}%';
  }

  /// Check if progress has changed significantly (for optimization)
  static bool hasSignificantProgressChange(
    DownloadTask oldTask,
    DownloadTask newTask, {
    double threshold = 0.01, // 1% threshold
  }) {
    return (newTask.progress - oldTask.progress).abs() >= threshold;
  }

  /// Get download duration
  static Duration getDownloadDuration(DownloadTask task) {
    if (task.startedAt == null) return Duration.zero;

    final endTime = task.completedAt ?? DateTime.now();
    return endTime.difference(task.startedAt!);
  }

  /// Get formatted duration string
  static String getDurationString(DownloadTask task) {
    final duration = getDownloadDuration(task);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
