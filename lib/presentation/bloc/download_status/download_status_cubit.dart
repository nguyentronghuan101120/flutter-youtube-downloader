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
import '../../../domain/usecases/download/is_in_system_downloads.dart';
import '../../../domain/usecases/download/open_file.dart';
import '../../../domain/usecases/download/move_to_system_downloads.dart';
import '../../../domain/entities/download_progress.dart';
import '../../../core/constants/app_constants.dart';
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
  final IsInSystemDownloads _isInSystemDownloads;
  final OpenFile _openFile;
  final MoveToSystemDownloads _moveToSystemDownloads;

  StreamSubscription<DownloadProgress>? _progressSubscription;
  String? _currentActiveTaskId;
  Timer? _queueRefreshTimer;

  DownloadStatusCubit({
    required GetActiveDownloads getActiveDownloads,
    required GetQueuedDownloads getQueuedDownloads,
    required GetCompletedDownloads getCompletedDownloads,
    required PauseDownload pauseDownload,
    required ResumeDownload resumeDownload,
    required CancelDownload cancelDownload,
    required GetDownloadProgressStream getDownloadProgressStream,
    required IsInSystemDownloads isInSystemDownloads,
    required OpenFile openFile,
    required MoveToSystemDownloads moveToSystemDownloads,
  }) : _getActiveDownloads = getActiveDownloads,
       _getQueuedDownloads = getQueuedDownloads,
       _getCompletedDownloads = getCompletedDownloads,
       _pauseDownload = pauseDownload,
       _resumeDownload = resumeDownload,
       _cancelDownload = cancelDownload,
       _getDownloadProgressStream = getDownloadProgressStream,
       _isInSystemDownloads = isInSystemDownloads,
       _openFile = openFile,
       _moveToSystemDownloads = moveToSystemDownloads,
       super(const DownloadStatusState.initial());

  @override
  Future<void> close() {
    _progressSubscription?.cancel();
    _queueRefreshTimer?.cancel();
    return super.close();
  }

  Future<void> loadQueueStatus() async {
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
                    startPeriodicRefresh();
                  } else {
                    // Stop any existing progress stream and periodic refresh if no active downloads
                    _stopProgressStream();
                    stopPeriodicRefresh();
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

  // Start optimized periodic refresh for queue status
  void startPeriodicRefresh() {
    stopPeriodicRefresh(); // Stop any existing timer first
    // Refresh every 500ms for optimized performance
    _queueRefreshTimer = Timer.periodic(
      Duration(milliseconds: AppConstants.progressUpdateInterval),
      (timer) {
        loadQueueStatus();
      },
    );
  }

  // Stop periodic refresh
  void stopPeriodicRefresh() {
    _queueRefreshTimer?.cancel();
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
          // If no more active downloads, stop refresh
          // (Handled in loadQueueStatus)
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
          // (Handled in loadQueueStatus)
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
          // (Handled in loadQueueStatus)
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

  Future<bool> isInSystemDownloads(String filePath) async {
    try {
      return await _isInSystemDownloads.execute(filePath);
    } catch (e) {
      developer.log(
        '[download_status_cubit.dart] - Error checking system downloads: $e',
      );
      return false;
    }
  }

  Future<bool> openFile(String filePath) async {
    try {
      return await _openFile.execute(filePath);
    } catch (e) {
      developer.log('[download_status_cubit.dart] - Error opening file: $e');
      return false;
    }
  }

  Future<String?> moveToSystemDownloads(String filePath) async {
    try {
      return await _moveToSystemDownloads.execute(filePath);
    } catch (e) {
      developer.log(
        '[download_status_cubit.dart] - Error moving file to system downloads: $e',
      );
      return null;
    }
  }
}
