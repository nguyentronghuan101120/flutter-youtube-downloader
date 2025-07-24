import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_task.freezed.dart';
part 'download_task.g.dart';

enum DownloadStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

@freezed
class DownloadTask with _$DownloadTask {
  const factory DownloadTask({
    required String id,
    required String videoId,
    required String title,
    required String url,
    required String format,
    required String quality,
    required String outputPath,
    required DownloadStatus status,
    required int bytesDownloaded,
    required int totalBytes,
    required double progress,
    required DateTime createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorMessage,
    @Default(0) int retryCount,
    @Default(true) bool isResumable,
  }) = _DownloadTask;

  factory DownloadTask.fromJson(Map<String, dynamic> json) =>
      _$DownloadTaskFromJson(json);
}

// Extension để giữ lại các helper methods
extension DownloadTaskUtils on DownloadTask {
  /// Updates progress based on bytes downloaded
  DownloadTask updateProgress(int bytesDownloaded, int totalBytes) {
    final progress = totalBytes > 0 ? bytesDownloaded / totalBytes : 0.0;
    return copyWith(
      bytesDownloaded: bytesDownloaded,
      totalBytes: totalBytes,
      progress: progress,
    );
  }

  /// Updates status and related timestamps
  DownloadTask updateStatus(DownloadStatus newStatus) {
    DateTime? startedAt = this.startedAt;
    DateTime? completedAt = this.completedAt;

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

    return copyWith(
      status: newStatus,
      startedAt: startedAt,
      completedAt: completedAt,
    );
  }

  /// Increments retry count
  DownloadTask incrementRetryCount() {
    return copyWith(retryCount: retryCount + 1);
  }

  /// Sets error message
  DownloadTask setError(String errorMessage) {
    return copyWith(status: DownloadStatus.failed, errorMessage: errorMessage);
  }

  /// Checks if download is in progress
  bool get isInProgress => status == DownloadStatus.downloading;

  /// Checks if download is completed
  bool get isCompleted => status == DownloadStatus.completed;

  /// Checks if download failed
  bool get isFailed => status == DownloadStatus.failed;

  /// Checks if download can be resumed
  bool get canResume =>
      isResumable &&
      (status == DownloadStatus.paused || status == DownloadStatus.failed);

  /// Gets formatted file size
  String get formattedFileSize {
    if (totalBytes == 0) return 'Unknown size';

    const units = ['B', 'KB', 'MB', 'GB'];
    double size = totalBytes.toDouble();
    int unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  /// Gets formatted downloaded size
  String get formattedDownloadedSize {
    if (bytesDownloaded == 0) return '0 B';

    const units = ['B', 'KB', 'MB', 'GB'];
    double size = bytesDownloaded.toDouble();
    int unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }
}
