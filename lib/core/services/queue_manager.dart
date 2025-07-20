import 'dart:async';
import 'package:injectable/injectable.dart';
import '../../domain/entities/download_task.dart';

enum QueuePriority { low, normal, high, urgent }

class QueuedDownloadTask {
  final DownloadTask task;
  final QueuePriority priority;
  final DateTime addedAt;
  final Completer<DownloadTask> completer;

  QueuedDownloadTask({
    required this.task,
    this.priority = QueuePriority.normal,
    required this.addedAt,
    required this.completer,
  });
}

@injectable
class QueueManager {
  final List<QueuedDownloadTask> _queue = [];
  final Map<String, QueuedDownloadTask> _activeDownloads = {};
  final int _maxConcurrentDownloads;
  final StreamController<List<QueuedDownloadTask>> _queueController;
  final StreamController<Map<String, QueuedDownloadTask>> _activeController;

  QueueManager({int maxConcurrentDownloads = 3})
    : _maxConcurrentDownloads = maxConcurrentDownloads,
      _queueController = StreamController<List<QueuedDownloadTask>>.broadcast(),
      _activeController =
          StreamController<Map<String, QueuedDownloadTask>>.broadcast();

  /// Adds a download task to the queue
  Future<DownloadTask> addToQueue(
    DownloadTask task, {
    QueuePriority priority = QueuePriority.normal,
  }) async {
    final completer = Completer<DownloadTask>();
    final queuedTask = QueuedDownloadTask(
      task: task,
      priority: priority,
      addedAt: DateTime.now(),
      completer: completer,
    );

    _queue.add(queuedTask);
    _sortQueue();
    _notifyQueueUpdate();

    // Try to start download if possible
    _processQueue();

    return completer.future;
  }

  /// Removes a task from the queue
  bool removeFromQueue(String taskId) {
    final index = _queue.indexWhere((task) => task.task.id == taskId);
    if (index != -1) {
      final removedTask = _queue.removeAt(index);
      removedTask.completer.completeError('Task removed from queue');
      _notifyQueueUpdate();
      return true;
    }
    return false;
  }

  /// Changes priority of a queued task
  bool changePriority(String taskId, QueuePriority newPriority) {
    final index = _queue.indexWhere((task) => task.task.id == taskId);
    if (index != -1) {
      final task = _queue[index];
      final updatedTask = QueuedDownloadTask(
        task: task.task,
        priority: newPriority,
        addedAt: task.addedAt,
        completer: task.completer,
      );
      _queue[index] = updatedTask;
      _sortQueue();
      _notifyQueueUpdate();
      return true;
    }
    return false;
  }

  /// Pauses a download and returns it to queue
  bool pauseDownload(String taskId) {
    final activeTask = _activeDownloads[taskId];
    if (activeTask != null) {
      _activeDownloads.remove(taskId);

      // Add back to queue with same priority
      _queue.add(activeTask);
      _sortQueue();

      _notifyQueueUpdate();
      _notifyActiveUpdate();
      _processQueue();

      return true;
    }
    return false;
  }

  /// Completes a download and removes it from active
  void completeDownload(String taskId, DownloadTask result) {
    final activeTask = _activeDownloads[taskId];
    if (activeTask != null) {
      _activeDownloads.remove(taskId);
      activeTask.completer.complete(result);

      _notifyActiveUpdate();
      _processQueue();
    }
  }

  /// Fails a download and removes it from active
  void failDownload(String taskId, String error) {
    final activeTask = _activeDownloads[taskId];
    if (activeTask != null) {
      _activeDownloads.remove(taskId);
      activeTask.completer.completeError(error);

      _notifyActiveUpdate();
      _processQueue();
    }
  }

  /// Gets current queue
  List<QueuedDownloadTask> get queue => List.unmodifiable(_queue);

  /// Gets active downloads
  Map<String, QueuedDownloadTask> get activeDownloads =>
      Map.unmodifiable(_activeDownloads);

  /// Gets queue stream
  Stream<List<QueuedDownloadTask>> get queueStream => _queueController.stream;

  /// Gets active downloads stream
  Stream<Map<String, QueuedDownloadTask>> get activeDownloadsStream =>
      _activeController.stream;

  /// Gets queue size
  int get queueSize => _queue.length;

  /// Gets active downloads count
  int get activeDownloadsCount => _activeDownloads.length;

  /// Checks if queue is empty
  bool get isQueueEmpty => _queue.isEmpty;

  /// Checks if can start more downloads
  bool get canStartMoreDownloads =>
      _activeDownloads.length < _maxConcurrentDownloads;

  /// Processes the queue and starts downloads if possible
  void _processQueue() {
    while (_queue.isNotEmpty && canStartMoreDownloads) {
      final nextTask = _queue.removeAt(0);
      _activeDownloads[nextTask.task.id] = nextTask;

      _notifyQueueUpdate();
      _notifyActiveUpdate();
    }
  }

  /// Sorts queue by priority and time added
  void _sortQueue() {
    _queue.sort((a, b) {
      // First sort by priority
      final priorityComparison = b.priority.index.compareTo(a.priority.index);
      if (priorityComparison != 0) return priorityComparison;

      // Then by time added (FIFO for same priority)
      return a.addedAt.compareTo(b.addedAt);
    });
  }

  /// Notifies queue update
  void _notifyQueueUpdate() {
    if (!_queueController.isClosed) {
      _queueController.add(queue);
    }
  }

  /// Notifies active downloads update
  void _notifyActiveUpdate() {
    if (!_activeController.isClosed) {
      _activeController.add(activeDownloads);
    }
  }

  /// Clears the queue
  void clearQueue() {
    for (final task in _queue) {
      task.completer.completeError('Queue cleared');
    }
    _queue.clear();
    _notifyQueueUpdate();
  }

  /// Disposes all resources
  void dispose() {
    _queueController.close();
    _activeController.close();

    // Complete all pending tasks with error
    for (final task in _queue) {
      task.completer.completeError('Queue manager disposed');
    }
    for (final task in _activeDownloads.values) {
      task.completer.completeError('Queue manager disposed');
    }

    _queue.clear();
    _activeDownloads.clear();
  }
}
