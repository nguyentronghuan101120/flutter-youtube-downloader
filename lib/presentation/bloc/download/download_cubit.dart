import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../domain/entities/download_task.dart';
import '../../../domain/entities/video_info.dart';
import '../../../domain/usecases/download/start_download.dart';
import '../../../domain/usecases/download/pause_download.dart';
import '../../../domain/usecases/download/resume_download.dart';
import '../../../domain/usecases/download/cancel_download.dart';
import '../../../domain/usecases/download/get_active_downloads.dart';
import '../../../domain/usecases/download/get_queued_downloads.dart';
import '../../../domain/usecases/download/get_completed_downloads.dart';
import '../../../domain/usecases/download/get_download_by_id.dart';
import '../../../domain/repositories/download_repository.dart';
import '../../../core/constants/download_status.dart';
import 'download_state.dart';
import 'dart:async';

@injectable
class DownloadCubit extends Cubit<DownloadState> {
  final StartDownload _startDownload;
  final PauseDownload _pauseDownload;
  final ResumeDownload _resumeDownload;
  final CancelDownload _cancelDownload;
  final GetActiveDownloads _getActiveDownloads;
  final GetQueuedDownloads _getQueuedDownloads;
  final GetCompletedDownloads _getCompletedDownloads;
  final GetDownloadById _getDownloadById;

  DownloadCubit({
    required StartDownload startDownload,
    required PauseDownload pauseDownload,
    required ResumeDownload resumeDownload,
    required CancelDownload cancelDownload,
    required GetActiveDownloads getActiveDownloads,
    required GetQueuedDownloads getQueuedDownloads,
    required GetCompletedDownloads getCompletedDownloads,
    required GetDownloadById getDownloadById,
  }) : _startDownload = startDownload,
       _pauseDownload = pauseDownload,
       _resumeDownload = resumeDownload,
       _cancelDownload = cancelDownload,
       _getActiveDownloads = getActiveDownloads,
       _getQueuedDownloads = getQueuedDownloads,
       _getCompletedDownloads = getCompletedDownloads,
       _getDownloadById = getDownloadById,
       super(const DownloadState.initial());

  Future<void> prepareDownload(VideoInfo videoInfo) async {
    emit(const DownloadState.analyzing());

    try {
      final videoStreams = videoInfo.videoStreams;
      final audioStreams = videoInfo.audioStreams;

      developer.log(
        '[download_cubit.dart] - Video streams count: ${videoStreams.length}',
      );
      developer.log(
        '[download_cubit.dart] - Audio streams count: ${audioStreams.length}',
      );

      emit(
        DownloadState.ready(
          videoInfo: videoInfo,
          videoStreams: videoStreams,
          audioStreams: audioStreams,
        ),
      );
    } catch (e) {
      emit(DownloadState.failed(message: 'Failed to analyze video: $e'));
    }
  }

  Future<void> startDownload({
    required String url,
    required String format,
    required String quality,
    String? outputPath,
  }) async {
    emit(
      DownloadState.downloading(
        task: DownloadTask(
          id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
          videoId: _extractVideoId(url),
          title: _extractTitle(url),
          url: url,
          format: format,
          quality: quality,
          outputPath: outputPath ?? await _getDefaultOutputPath(),
          status: DownloadStatus.downloading,
          bytesDownloaded: 0,
          totalBytes: 0,
          progress: 0.0,
          createdAt: DateTime.now(),
          startedAt: DateTime.now(),
        ),
        progress: 0.0,
        speed: '0 KB/s',
        eta: 'Calculating...',
      ),
    );

    final params = StartDownloadParams(
      videoId: _extractVideoId(url),
      title: _extractTitle(url),
      url: url,
      format: format,
      quality: quality,
      outputPath: outputPath ?? await _getDefaultOutputPath(),
    );

    final result = await _startDownload.execute(params);

    result.when(
      success: (task) {
        _monitorDownloadProgress(task);
      },
      failure: (error) {
        emit(DownloadState.failed(message: error));
      },
    );
  }

  Future<void> pauseDownload(String taskId) async {
    final result = await _pauseDownload.execute(taskId);

    result.when(
      success: (_) {
        // Get the updated task to emit paused state
        _getDownloadById.execute(taskId).then((taskResult) {
          taskResult.when(
            success: (task) {
              emit(DownloadState.paused(task: task, progress: task.progress));
            },
            failure: (error) {
              emit(DownloadState.failed(message: error));
            },
          );
        });
      },
      failure: (error) {
        emit(DownloadState.failed(message: error));
      },
    );
  }

  Future<void> resumeDownload(String taskId) async {
    final result = await _resumeDownload.execute(taskId);

    result.when(
      success: (_) {
        // Get the updated task to monitor progress
        _getDownloadById.execute(taskId).then((taskResult) {
          taskResult.when(
            success: (task) {
              _monitorDownloadProgress(task);
            },
            failure: (error) {
              emit(DownloadState.failed(message: error));
            },
          );
        });
      },
      failure: (error) {
        emit(DownloadState.failed(message: error));
      },
    );
  }

  Future<void> cancelDownload(String taskId) async {
    final result = await _cancelDownload.execute(taskId);

    result.when(
      success: (_) {
        _refreshQueueStatus();
      },
      failure: (error) {
        emit(DownloadState.failed(message: error));
      },
    );
  }

  Future<void> loadQueueStatus() async {
    emit(const DownloadState.loading());

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
                  emit(
                    DownloadState.queue(
                      activeDownloads: activeDownloads,
                      queuedDownloads: queuedDownloads,
                      completedDownloads: completedDownloads,
                    ),
                  );
                },
                failure: (failure) =>
                    emit(DownloadState.failed(message: failure)),
              );
            },
            failure: (failure) => emit(DownloadState.failed(message: failure)),
          );
        },
        failure: (failure) => emit(DownloadState.failed(message: failure)),
      );
    } catch (e) {
      emit(DownloadState.failed(message: 'Failed to load queue: $e'));
    }
  }

  void _monitorDownloadProgress(DownloadTask task) {
    Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      try {
        final result = await _getDownloadById.execute(task.id);
        result.when(
          success: (updatedTask) {
            if (updatedTask.status == DownloadStatus.completed) {
              timer.cancel();
              emit(
                DownloadState.completed(
                  task: updatedTask,
                  filePath: updatedTask.outputPath,
                ),
              );
            } else if (updatedTask.status == DownloadStatus.failed) {
              timer.cancel();
              emit(DownloadState.failed(message: 'Download failed'));
            } else {
              emit(
                DownloadState.downloading(
                  task: updatedTask,
                  progress: updatedTask.progress,
                  speed:
                      '${(updatedTask.bytesDownloaded / 1024).toStringAsFixed(1)} KB/s',
                  eta: _calculateEta(
                    updatedTask.progress,
                    updatedTask.bytesDownloaded,
                    updatedTask.totalBytes,
                  ),
                ),
              );
            }
          },
          failure: (error) {
            timer.cancel();
            emit(DownloadState.failed(message: error));
          },
        );
      } catch (e) {
        timer.cancel();
        emit(DownloadState.failed(message: 'Failed to monitor progress: $e'));
      }
    });
  }

  void _refreshQueueStatus() {
    loadQueueStatus();
  }

  String _extractVideoId(String url) {
    final patterns = [
      RegExp(
        r'(?:youtube\.com/watch\?v=|youtu\.be/|youtube\.com/embed/)([a-zA-Z0-9_-]{11})',
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null) {
        return match.group(1) ?? '';
      }
    }
    return '';
  }

  String _extractTitle(String url) {
    return 'Video_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<String> _getDefaultOutputPath() async {
    try {
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        return '${downloadsDir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      }
      final dir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${dir.path}/downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      return '${downloadsDir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    } catch (e) {
      final tempDir = await getTemporaryDirectory();
      return '${tempDir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    }
  }

  String _calculateEta(double progress, int downloadedBytes, int totalBytes) {
    if (progress <= 0) return 'Calculating...';

    final remainingBytes = totalBytes - downloadedBytes;
    final bytesPerSecond = downloadedBytes / (progress * 100);

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
}
