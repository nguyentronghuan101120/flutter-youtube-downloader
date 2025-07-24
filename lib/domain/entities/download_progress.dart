import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_progress.freezed.dart';

@freezed
class DownloadProgress with _$DownloadProgress {
  const factory DownloadProgress({
    required String taskId,
    required double progress,
    required String speed,
    required String eta,
    required int downloadedBytes,
    required int totalBytes,
  }) = _DownloadProgress;
}
