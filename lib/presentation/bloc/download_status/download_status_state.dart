import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/download_task.dart';

part 'download_status_state.freezed.dart';

@freezed
class DownloadStatusState with _$DownloadStatusState {
  const factory DownloadStatusState.initial() = _Initial;

  const factory DownloadStatusState.loading() = _Loading;

  const factory DownloadStatusState.queue({
    required List<DownloadTask> activeDownloads,
    required List<DownloadTask> queuedDownloads,
    required List<DownloadTask> completedDownloads,
  }) = _Queue;

  const factory DownloadStatusState.downloading({
    required DownloadTask task,
    required double progress,
    required String speed,
    required String eta,
  }) = _Downloading;

  const factory DownloadStatusState.paused({
    required DownloadTask task,
    required double progress,
  }) = _Paused;

  const factory DownloadStatusState.completed({
    required DownloadTask task,
    required String filePath,
  }) = _Completed;

  const factory DownloadStatusState.failed({
    required String message,
    DownloadTask? task,
  }) = _Failed;
}
