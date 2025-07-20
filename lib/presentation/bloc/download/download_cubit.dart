import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/download_task.dart';
import '../../../core/constants/app_constants.dart';
import 'download_state.dart';

/// Cubit for managing download operations and state
class DownloadCubit extends Cubit<DownloadState> {
  // Queue management
  final List<DownloadTask> _downloadQueue = [];
  final List<DownloadTask> _activeDownloads = [];
  final List<DownloadTask> _completedDownloads = [];
  final List<DownloadTask> _failedDownloads = [];

  // Progress tracking
  final Map<String, double> _taskProgress = {};
  final Map<String, int> _taskDownloadedBytes = {};
  final Map<String, int> _taskTotalBytes = {};
  final Map<String, double> _taskSpeed = {};
  final Map<String, Duration> _taskEstimatedTime = {};

  // Stream subscriptions
  final Map<String, StreamSubscription> _downloadSubscriptions = {};

  // Timer for progress updates
  Timer? _progressTimer;

  DownloadCubit() : super(const DownloadInitial()) {
    _startProgressTimer();
  }

  @override
  Future<void> close() {
    _progressTimer?.cancel();
    _cancelAllDownloads();
    return super.close();
  }

  /// Add a new download task to the queue
  Future<void> addDownloadTask({
    required String videoId,
    required String title,
    required String formatId,
    required String outputPath,
  }) async {
    final task = DownloadTask(
      id: _generateTaskId(),
      videoId: videoId,
      title: title,
      formatId: formatId,
      outputPath: outputPath,
      status: DownloadStatus.pending,
      createdAt: DateTime.now(),
    );

    _downloadQueue.add(task);
    _emitQueueState();

    // Start processing queue if not at capacity
    if (_activeDownloads.length < AppConstants.maxConcurrentDownloads) {
      _processQueue();
    }
  }

  /// Start processing the download queue
  void _processQueue() {
    while (_downloadQueue.isNotEmpty &&
        _activeDownloads.length < AppConstants.maxConcurrentDownloads) {
      final task = _downloadQueue.removeAt(0);
      _startDownload(task);
    }
  }

  /// Start a specific download (simulated for now)
  Future<void> _startDownload(DownloadTask task) async {
    try {
      // Update task status
      final updatedTask = task.copyWith(status: DownloadStatus.downloading);
      _activeDownloads.add(updatedTask);
      _emitQueueState();

      // Initialize progress tracking
      _taskProgress[task.id] = 0.0;
      _taskDownloadedBytes[task.id] = 0;
      _taskTotalBytes[task.id] = 1000000; // Simulated total size
      _taskSpeed[task.id] = 0.0;
      _taskEstimatedTime[task.id] = Duration.zero;

      // Simulate download progress
      await _simulateDownload(task);
    } catch (e) {
      _handleDownloadFailure(task, e.toString());
    }
  }

  /// Simulate download progress (for testing)
  Future<void> _simulateDownload(DownloadTask task) async {
    const totalSteps = 100;
    const stepDelay = Duration(milliseconds: 100);

    for (int i = 0; i <= totalSteps; i++) {
      await Future.delayed(stepDelay);

      final progress = i / totalSteps;
      final downloadedBytes = (progress * _taskTotalBytes[task.id]!).toInt();
      final speed = 1000000.0; // 1MB/s simulated speed

      _updateProgress(
        task.id,
        progress,
        downloadedBytes,
        _taskTotalBytes[task.id]!,
        speed,
      );

      // Check if task was cancelled
      if (!_activeDownloads.any((t) => t.id == task.id)) {
        return;
      }
    }

    // Simulate successful completion
    _handleDownloadSuccess(task, task.outputPath);
  }

  /// Update download progress
  void _updateProgress(
    String taskId,
    double progress,
    int downloadedBytes,
    int totalBytes,
    double speed,
  ) {
    _taskProgress[taskId] = progress;
    _taskDownloadedBytes[taskId] = downloadedBytes;
    _taskTotalBytes[taskId] = totalBytes;
    _taskSpeed[taskId] = speed;

    // Calculate estimated time remaining
    if (speed > 0 && progress < 1.0) {
      final remainingBytes = totalBytes - downloadedBytes;
      final estimatedSeconds = remainingBytes / speed;
      _taskEstimatedTime[taskId] = Duration(seconds: estimatedSeconds.toInt());
    }

    // Emit progress state
    emit(
      DownloadProgressState(
        taskProgress: Map.from(_taskProgress),
        taskDownloadedBytes: Map.from(_taskDownloadedBytes),
        taskTotalBytes: Map.from(_taskTotalBytes),
        taskSpeed: Map.from(_taskSpeed),
        taskEstimatedTime: Map.from(_taskEstimatedTime),
      ),
    );
  }

  /// Handle successful download completion
  void _handleDownloadSuccess(DownloadTask task, String filePath) {
    // Remove from active downloads
    _activeDownloads.removeWhere((t) => t.id == task.id);

    // Add to completed downloads
    final completedTask = task.copyWith(
      status: DownloadStatus.completed,
      completedAt: DateTime.now(),
    );
    _completedDownloads.add(completedTask);

    // Clean up progress tracking
    _cleanupTaskProgress(task.id);

    // Emit states
    emit(
      DownloadCompleted(
        task: completedTask,
        filePath: filePath,
        fileSize: _taskTotalBytes[task.id] ?? 0,
      ),
    );
    _emitQueueState();

    // Process next item in queue
    _processQueue();
  }

  /// Handle download failure
  void _handleDownloadFailure(DownloadTask task, String error) {
    // Remove from active downloads
    _activeDownloads.removeWhere((t) => t.id == task.id);

    // Add to failed downloads
    final failedTask = task.copyWith(
      status: DownloadStatus.failed,
      errorMessage: error,
      completedAt: DateTime.now(),
    );
    _failedDownloads.add(failedTask);

    // Clean up progress tracking
    _cleanupTaskProgress(task.id);

    // Emit states
    emit(DownloadFailed(task: failedTask, error: error));
    _emitQueueState();

    // Process next item in queue
    _processQueue();
  }

  /// Pause a specific download
  Future<void> pauseDownload(String taskId) async {
    final task = _activeDownloads.firstWhere(
      (t) => t.id == taskId,
      orElse: () => throw Exception('Download not found'),
    );

    // Cancel the download stream
    await _downloadSubscriptions[taskId]?.cancel();
    _downloadSubscriptions.remove(taskId);

    // Update task status
    final pausedTask = task.copyWith(status: DownloadStatus.paused);
    _activeDownloads.remove(task);

    // Add back to queue at the front
    _downloadQueue.insert(0, pausedTask);

    // Emit states
    emit(
      DownloadPaused(
        task: pausedTask,
        progress: _taskProgress[taskId] ?? 0.0,
        downloadedBytes: _taskDownloadedBytes[taskId] ?? 0,
        totalBytes: _taskTotalBytes[taskId] ?? 0,
      ),
    );
    _emitQueueState();

    // Process queue to start next download
    _processQueue();
  }

  /// Resume a paused download
  Future<void> resumeDownload(String taskId) async {
    final taskIndex = _downloadQueue.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) {
      throw Exception('Download not found in queue');
    }

    final task = _downloadQueue.removeAt(taskIndex);
    final resumedTask = task.copyWith(status: DownloadStatus.downloading);

    // Add to active downloads
    _activeDownloads.add(resumedTask);
    _emitQueueState();

    // Start the download
    await _startDownload(resumedTask);
  }

  /// Cancel a download
  Future<void> cancelDownload(String taskId) async {
    // Cancel if active
    if (_activeDownloads.any((t) => t.id == taskId)) {
      await _downloadSubscriptions[taskId]?.cancel();
      _downloadSubscriptions.remove(taskId);

      final task = _activeDownloads.firstWhere((t) => t.id == taskId);
      _activeDownloads.remove(task);
      _cleanupTaskProgress(taskId);

      emit(DownloadCancelled(task: task));
      _emitQueueState();
      _processQueue();
    }

    // Remove from queue
    _downloadQueue.removeWhere((t) => t.id == taskId);
    _emitQueueState();
  }

  /// Cancel all downloads
  Future<void> _cancelAllDownloads() async {
    // Cancel active downloads
    for (final subscription in _downloadSubscriptions.values) {
      await subscription.cancel();
    }
    _downloadSubscriptions.clear();

    // Clear all collections
    _activeDownloads.clear();
    _downloadQueue.clear();
    _taskProgress.clear();
    _taskDownloadedBytes.clear();
    _taskTotalBytes.clear();
    _taskSpeed.clear();
    _taskEstimatedTime.clear();

    emit(const DownloadInitial());
  }

  /// Get download task by ID
  DownloadTask? getTaskById(String taskId) {
    return _activeDownloads
        .cast<DownloadTask?>()
        .followedBy(_downloadQueue.cast<DownloadTask?>())
        .followedBy(_completedDownloads.cast<DownloadTask?>())
        .followedBy(_failedDownloads.cast<DownloadTask?>())
        .firstWhere((task) => task?.id == taskId, orElse: () => null);
  }

  /// Get all tasks
  List<DownloadTask> getAllTasks() {
    return [
      ..._activeDownloads,
      ..._downloadQueue,
      ..._completedDownloads,
      ..._failedDownloads,
    ];
  }

  /// Get tasks by status
  List<DownloadTask> getTasksByStatus(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.pending:
        return List.from(_downloadQueue);
      case DownloadStatus.downloading:
        return List.from(_activeDownloads);
      case DownloadStatus.completed:
        return List.from(_completedDownloads);
      case DownloadStatus.failed:
        return List.from(_failedDownloads);
      case DownloadStatus.paused:
        return _downloadQueue
            .where((t) => t.status == DownloadStatus.paused)
            .toList();
      case DownloadStatus.cancelled:
        return [];
    }
  }

  /// Clear completed downloads
  void clearCompletedDownloads() {
    _completedDownloads.clear();
    _emitQueueState();
  }

  /// Clear failed downloads
  void clearFailedDownloads() {
    _failedDownloads.clear();
    _emitQueueState();
  }

  /// Retry failed download
  Future<void> retryFailedDownload(String taskId) async {
    final failedTask = _failedDownloads.firstWhere(
      (t) => t.id == taskId,
      orElse: () => throw Exception('Failed download not found'),
    );

    _failedDownloads.remove(failedTask);

    // Reset task and add to queue
    final retryTask = failedTask.copyWith(
      status: DownloadStatus.pending,
      createdAt: DateTime.now(),
    );

    _downloadQueue.add(retryTask);
    _emitQueueState();
    _processQueue();
  }

  /// Emit queue state
  void _emitQueueState() {
    emit(
      DownloadQueueState(
        queuedTasks: List.from(_downloadQueue),
        activeTasks: List.from(_activeDownloads),
        completedTasks: List.from(_completedDownloads),
        failedTasks: List.from(_failedDownloads),
        maxConcurrentDownloads: AppConstants.maxConcurrentDownloads,
      ),
    );
  }

  /// Start progress timer
  void _startProgressTimer() {
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_activeDownloads.isNotEmpty) {
        emit(
          DownloadProgressState(
            taskProgress: Map.from(_taskProgress),
            taskDownloadedBytes: Map.from(_taskDownloadedBytes),
            taskTotalBytes: Map.from(_taskTotalBytes),
            taskSpeed: Map.from(_taskSpeed),
            taskEstimatedTime: Map.from(_taskEstimatedTime),
          ),
        );
      }
    });
  }

  /// Clean up task progress data
  void _cleanupTaskProgress(String taskId) {
    _taskProgress.remove(taskId);
    _taskDownloadedBytes.remove(taskId);
    _taskTotalBytes.remove(taskId);
    _taskSpeed.remove(taskId);
    _taskEstimatedTime.remove(taskId);
  }

  /// Generate unique task ID
  String _generateTaskId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
