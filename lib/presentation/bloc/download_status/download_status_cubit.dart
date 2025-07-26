import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'dart:developer' as developer;
import 'dart:async';
import '../../../domain/usecases/download/get_active_downloads.dart';
import '../../../domain/usecases/download/get_queued_downloads.dart';
import '../../../domain/usecases/download/get_completed_downloads.dart';
import '../../../domain/usecases/download/pause_download.dart';
import '../../../domain/usecases/download/resume_download.dart';
import '../../../domain/usecases/download/cancel_download.dart';
import '../../../domain/usecases/download/get_download_progress_stream.dart';
import '../../../domain/entities/download_progress.dart';
import 'download_status_state.dart';

@injectable
class DownloadStatusCubit extends Cubit<DownloadStatusState> {
  final GetActiveDownloads _getActiveDownloads;
  final GetQueuedDownloads _getQueuedDownloads;
  final GetCompletedDownloads _getCompletedDownloads;
  final PauseDownload _pauseDownload;
  final ResumeDownload _resumeDownload;
  final CancelDownload _cancelDownload;
  final GetDownloadProgressStream _getDownloadProgressStream;

  StreamSubscription<DownloadProgress>? _progressSubscription;
  String? _currentActiveTaskId;
  Timer? _queueRefreshTimer;
  bool _isLoading = false;

  DownloadStatusCubit({
    required GetActiveDownloads getActiveDownloads,
    required GetQueuedDownloads getQueuedDownloads,
    required GetCompletedDownloads getCompletedDownloads,
    required PauseDownload pauseDownload,
    required ResumeDownload resumeDownload,
    required CancelDownload cancelDownload,
    required GetDownloadProgressStream getDownloadProgressStream,
  }) : _getActiveDownloads = getActiveDownloads,
       _getQueuedDownloads = getQueuedDownloads,
       _getCompletedDownloads = getCompletedDownloads,
       _pauseDownload = pauseDownload,
       _resumeDownload = resumeDownload,
       _cancelDownload = cancelDownload,
       _getDownloadProgressStream = getDownloadProgressStream,
       super(const DownloadStatusState.initial());

  @override
  Future<void> close() {
    _progressSubscription?.cancel();
    _queueRefreshTimer?.cancel();
    return super.close();
  }

  Future<void> loadQueueStatus() async {
    if (_isLoading) return; // Prevent multiple simultaneous loads

    _isLoading = true;
    emit(const DownloadStatusState.loading());

    try {
      final activeResult = await _getActiveDownloads.execute();
      final queuedResult = await _getQueuedDownloads.execute();
      final completedResult = await _getCompletedDownloads.execute();

      activeResult.when(
        success: (activeDownloads) {
          queuedResult.when(
            success: (queuedDownloads) {
              completedResult.when(
                success: (completedDownloads) {
                  developer.log(
                    '[download_status_cubit.dart] - Loaded queue status: ${activeDownloads.length} active, ${queuedDownloads.length} queued, ${completedDownloads.length} completed',
                  );

                  // Always show queue state with all downloads
                  emit(
                    DownloadStatusState.queue(
                      activeDownloads: activeDownloads,
                      queuedDownloads: queuedDownloads,
                      completedDownloads: completedDownloads,
                    ),
                  );

                  // If there are active downloads, start progress stream for the first one
                  if (activeDownloads.isNotEmpty) {
                    final activeDownload = activeDownloads.first;
                    _startProgressStream(activeDownload.id);
                  } else {
                    // Stop any existing progress stream if no active downloads
                    _stopProgressStream();
                  }
                },
                failure: (error) {
                  emit(DownloadStatusState.failed(message: error));
                },
              );
            },
            failure: (error) {
              emit(DownloadStatusState.failed(message: error));
            },
          );
        },
        failure: (error) {
          emit(DownloadStatusState.failed(message: error));
        },
      );
    } catch (e) {
      emit(
        DownloadStatusState.failed(message: 'Failed to load queue status: $e'),
      );
    } finally {
      _isLoading = false;
    }
  }

  void _startProgressStream(String taskId) {
    // Stop existing stream if different task
    if (_currentActiveTaskId != taskId) {
      _stopProgressStream();
      _currentActiveTaskId = taskId;
    }

    // Start new progress stream with faster updates
    _getDownloadProgressStream.execute(taskId).then((stream) {
      _progressSubscription = stream.listen(
        (progress) {
          developer.log(
            '[download_status_cubit.dart] - Progress update: ${(progress.progress * 100).toStringAsFixed(1)}% - ${progress.speed}',
          );

          // Update the downloading state with new progress immediately
          state.when(
            downloading: (task, _, __, ___) {
              emit(
                DownloadStatusState.downloading(
                  task: task.copyWith(
                    progress: progress.progress,
                    bytesDownloaded: progress.downloadedBytes,
                    totalBytes: progress.totalBytes,
                  ),
                  progress: progress.progress,
                  speed: progress.speed,
                  eta: progress.eta,
                ),
              );
            },
            initial: () {},
            loading: () {},
            queue: (_, __, ___) {},
            paused: (_, __) {},
            completed: (_, __) {},
            failed: (_, __) {},
          );
        },
        onError: (error) {
          developer.log(
            '[download_status_cubit.dart] - Progress stream error: $error',
          );
        },
      );
    });
  }

  void _stopProgressStream() {
    _progressSubscription?.cancel();
    _progressSubscription = null;
    _currentActiveTaskId = null;
  }

  // Start faster periodic refresh for queue status
  void startPeriodicRefresh() {
    _queueRefreshTimer?.cancel();
    // Refresh every 500ms for faster realtime updates
    _queueRefreshTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) {
      if (!_isLoading) {
        loadQueueStatus();
      }
    });
  }

  // Stop periodic refresh
  void stopPeriodicRefresh() {
    _queueRefreshTimer?.cancel();
  }

  // Force refresh queue status (useful when new downloads are added)
  Future<void> forceRefreshQueueStatus() async {
    _isLoading = false; // Reset loading state
    await loadQueueStatus();
  }

  Future<void> pauseDownload(String taskId) async {
    try {
      final result = await _pauseDownload.execute(taskId);

      result.when(
        success: (_) {
          developer.log(
            '[download_status_cubit.dart] - Download paused: $taskId',
          );
          // Reload queue status to reflect the change
          loadQueueStatus();
        },
        failure: (error) {
          emit(DownloadStatusState.failed(message: error));
        },
      );
    } catch (e) {
      emit(DownloadStatusState.failed(message: 'Failed to pause download: $e'));
    }
  }

  Future<void> resumeDownload(String taskId) async {
    try {
      final result = await _resumeDownload.execute(taskId);

      result.when(
        success: (_) {
          developer.log(
            '[download_status_cubit.dart] - Download resumed: $taskId',
          );
          // Reload queue status to reflect the change
          loadQueueStatus();
        },
        failure: (error) {
          emit(DownloadStatusState.failed(message: error));
        },
      );
    } catch (e) {
      emit(
        DownloadStatusState.failed(message: 'Failed to resume download: $e'),
      );
    }
  }

  Future<void> cancelDownload(String taskId) async {
    try {
      final result = await _cancelDownload.execute(taskId);

      result.when(
        success: (_) {
          developer.log(
            '[download_status_cubit.dart] - Download cancelled: $taskId',
          );
          // Reload queue status to reflect the change
          loadQueueStatus();
        },
        failure: (error) {
          emit(DownloadStatusState.failed(message: error));
        },
      );
    } catch (e) {
      emit(
        DownloadStatusState.failed(message: 'Failed to cancel download: $e'),
      );
    }
  }
}
