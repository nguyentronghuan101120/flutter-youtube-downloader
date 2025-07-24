import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/download_task.dart';
import '../../../domain/entities/video_info.dart';
import '../../../domain/entities/video_stream.dart';
import '../../../domain/entities/audio_stream.dart';

part 'download_state.freezed.dart';

@freezed
class DownloadState with _$DownloadState {
  const factory DownloadState.initial() = _Initial;

  const factory DownloadState.loading() = _Loading;

  const factory DownloadState.analyzing() = _Analyzing;

  const factory DownloadState.ready({
    required VideoInfo videoInfo,
    required List<VideoStream> videoStreams,
    required List<AudioStream> audioStreams,
  }) = _Ready;

  const factory DownloadState.downloading({
    required DownloadTask task,
    required double progress,
    required String speed,
    required String eta,
  }) = _Downloading;

  const factory DownloadState.paused({
    required DownloadTask task,
    required double progress,
  }) = _Paused;

  const factory DownloadState.completed({
    required DownloadTask task,
    required String filePath,
  }) = _Completed;

  const factory DownloadState.failed({
    required String message,
    DownloadTask? task,
  }) = _Failed;

  const factory DownloadState.queue({
    required List<DownloadTask> activeDownloads,
    required List<DownloadTask> queuedDownloads,
    required List<DownloadTask> completedDownloads,
  }) = _Queue;
}
