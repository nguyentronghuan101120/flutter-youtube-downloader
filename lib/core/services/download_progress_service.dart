import 'dart:async';
import 'dart:developer' as developer;
import '../../domain/entities/download_progress.dart';
import '../constants/download_status.dart';
import '../constants/app_constants.dart';
import '../utils/download_task_utils.dart';

class DownloadProgressService {
  final Map<String, StreamController<DownloadProgress>> _progressControllers =
      {};
  final Map<String, Timer> _progressTimers = {};
  final Function(String) _getTaskById;

  DownloadProgressService(this._getTaskById);

  /// Get progress stream for a task
  Stream<DownloadProgress> getProgressStream(String taskId) {
    if (!_progressControllers.containsKey(taskId)) {
      _progressControllers[taskId] =
          StreamController<DownloadProgress>.broadcast();
      _startProgressUpdates(taskId);
    }
    return _progressControllers[taskId]!.stream;
  }

  /// Start periodic progress updates
  void _startProgressUpdates(String taskId) {
    _progressTimers[taskId]?.cancel();

    _progressTimers[taskId] = Timer.periodic(
      Duration(milliseconds: AppConstants.progressUpdateInterval),
      (timer) async {
        try {
          final task = _getTaskById(taskId);
          if (task != null &&
              task.status == DownloadStatus.downloading &&
              task.startedAt != null) {
            final speed = DownloadTaskUtils.calculateSpeed(
              task.bytesDownloaded,
              task.startedAt!,
            );
            final eta = DownloadTaskUtils.calculateEta(
              task.bytesDownloaded,
              task.totalBytes,
              speed,
            );

            final progress = DownloadProgress(
              taskId: task.id,
              progress: task.progress,
              speed: speed,
              eta: eta,
              downloadedBytes: task.bytesDownloaded,
              totalBytes: task.totalBytes,
            );

            _progressControllers[taskId]?.add(progress);
          } else {
            _cleanupProgress(taskId);
          }
        } catch (e) {
          developer.log(
            '[download_progress_service.dart] - Error updating progress: $e',
          );
          _cleanupProgress(taskId);
        }
      },
    );
  }

  /// Cleanup progress tracking for a task
  void _cleanupProgress(String taskId) {
    _progressTimers[taskId]?.cancel();
    _progressTimers.remove(taskId);
    _progressControllers[taskId]?.close();
    _progressControllers.remove(taskId);
  }

  /// Cleanup progress tracking for a task (public method)
  void cleanupProgress(String taskId) {
    _cleanupProgress(taskId);
  }

  /// Dispose all progress tracking
  void dispose() {
    for (final timer in _progressTimers.values) {
      timer.cancel();
    }
    _progressTimers.clear();

    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();
  }
}
