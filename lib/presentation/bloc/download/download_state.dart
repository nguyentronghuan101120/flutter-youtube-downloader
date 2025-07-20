import 'package:equatable/equatable.dart';
import '../../../domain/entities/download_task.dart';

/// Base class for download states
abstract class DownloadState extends Equatable {
  const DownloadState();

  @override
  List<Object?> get props => [];
}

/// Initial state when no download is active
class DownloadInitial extends DownloadState {
  const DownloadInitial();
}

/// State when download is queued
class DownloadQueued extends DownloadState {
  final DownloadTask task;
  final int queuePosition;

  const DownloadQueued({required this.task, required this.queuePosition});

  @override
  List<Object?> get props => [task, queuePosition];
}

/// State when download is in progress
class DownloadInProgress extends DownloadState {
  final DownloadTask task;
  final double progress; // 0.0 to 1.0
  final int downloadedBytes;
  final int totalBytes;
  final double downloadSpeed; // bytes per second
  final Duration estimatedTimeRemaining;

  const DownloadInProgress({
    required this.task,
    required this.progress,
    required this.downloadedBytes,
    required this.totalBytes,
    required this.downloadSpeed,
    required this.estimatedTimeRemaining,
  });

  @override
  List<Object?> get props => [
    task,
    progress,
    downloadedBytes,
    totalBytes,
    downloadSpeed,
    estimatedTimeRemaining,
  ];
}

/// State when download is paused
class DownloadPaused extends DownloadState {
  final DownloadTask task;
  final double progress;
  final int downloadedBytes;
  final int totalBytes;

  const DownloadPaused({
    required this.task,
    required this.progress,
    required this.downloadedBytes,
    required this.totalBytes,
  });

  @override
  List<Object?> get props => [task, progress, downloadedBytes, totalBytes];
}

/// State when download is completed successfully
class DownloadCompleted extends DownloadState {
  final DownloadTask task;
  final String filePath;
  final int fileSize;

  const DownloadCompleted({
    required this.task,
    required this.filePath,
    required this.fileSize,
  });

  @override
  List<Object?> get props => [task, filePath, fileSize];
}

/// State when download failed
class DownloadFailed extends DownloadState {
  final DownloadTask task;
  final String error;
  final String? errorDetails;

  const DownloadFailed({
    required this.task,
    required this.error,
    this.errorDetails,
  });

  @override
  List<Object?> get props => [task, error, errorDetails];
}

/// State when download is cancelled
class DownloadCancelled extends DownloadState {
  final DownloadTask task;

  const DownloadCancelled({required this.task});

  @override
  List<Object?> get props => [task];
}

/// State for download queue management
class DownloadQueueState extends DownloadState {
  final List<DownloadTask> queuedTasks;
  final List<DownloadTask> activeTasks;
  final List<DownloadTask> completedTasks;
  final List<DownloadTask> failedTasks;
  final int maxConcurrentDownloads;

  const DownloadQueueState({
    required this.queuedTasks,
    required this.activeTasks,
    required this.completedTasks,
    required this.failedTasks,
    required this.maxConcurrentDownloads,
  });

  @override
  List<Object?> get props => [
    queuedTasks,
    activeTasks,
    completedTasks,
    failedTasks,
    maxConcurrentDownloads,
  ];

  /// Get total number of tasks
  int get totalTasks =>
      queuedTasks.length +
      activeTasks.length +
      completedTasks.length +
      failedTasks.length;

  /// Check if queue is full
  bool get isQueueFull => queuedTasks.length >= maxConcurrentDownloads * 2;

  /// Get overall progress
  double get overallProgress {
    if (totalTasks == 0) return 0.0;
    return completedTasks.length / totalTasks;
  }
}

/// State for download progress tracking
class DownloadProgressState extends DownloadState {
  final Map<String, double> taskProgress; // taskId -> progress (0.0 to 1.0)
  final Map<String, int> taskDownloadedBytes; // taskId -> downloaded bytes
  final Map<String, int> taskTotalBytes; // taskId -> total bytes
  final Map<String, double> taskSpeed; // taskId -> download speed (bytes/sec)
  final Map<String, Duration>
  taskEstimatedTime; // taskId -> estimated time remaining

  const DownloadProgressState({
    required this.taskProgress,
    required this.taskDownloadedBytes,
    required this.taskTotalBytes,
    required this.taskSpeed,
    required this.taskEstimatedTime,
  });

  @override
  List<Object?> get props => [
    taskProgress,
    taskDownloadedBytes,
    taskTotalBytes,
    taskSpeed,
    taskEstimatedTime,
  ];

  /// Get progress for specific task
  double getProgressForTask(String taskId) {
    return taskProgress[taskId] ?? 0.0;
  }

  /// Get downloaded bytes for specific task
  int getDownloadedBytesForTask(String taskId) {
    return taskDownloadedBytes[taskId] ?? 0;
  }

  /// Get total bytes for specific task
  int getTotalBytesForTask(String taskId) {
    return taskTotalBytes[taskId] ?? 0;
  }

  /// Get download speed for specific task
  double getSpeedForTask(String taskId) {
    return taskSpeed[taskId] ?? 0.0;
  }

  /// Get estimated time for specific task
  Duration getEstimatedTimeForTask(String taskId) {
    return taskEstimatedTime[taskId] ?? Duration.zero;
  }

  /// Get overall progress across all tasks
  double get overallProgress {
    if (taskProgress.isEmpty) return 0.0;

    final totalProgress = taskProgress.values.reduce((a, b) => a + b);
    return totalProgress / taskProgress.length;
  }

  /// Get total downloaded bytes across all tasks
  int get totalDownloadedBytes {
    return taskDownloadedBytes.values.fold(0, (sum, bytes) => sum + bytes);
  }

  /// Get total bytes across all tasks
  int get totalBytes {
    return taskTotalBytes.values.fold(0, (sum, bytes) => sum + bytes);
  }

  /// Get average download speed across all tasks
  double get averageSpeed {
    if (taskSpeed.isEmpty) return 0.0;

    final totalSpeed = taskSpeed.values.reduce((a, b) => a + b);
    return totalSpeed / taskSpeed.length;
  }
}
