import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/constants/download_status.dart';

part 'download_task.freezed.dart';
part 'download_task.g.dart';

@freezed
class DownloadTask with _$DownloadTask {
  const factory DownloadTask({
    required String id,
    required String videoId,
    required String title,
    required String url,
    required String format,
    required String quality,
    required String outputPath,
    required DownloadStatus status,
    required int bytesDownloaded,
    required int totalBytes,
    required double progress,
    required DateTime createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? pausedAt,
    DateTime? cancelledAt,
    String? errorMessage,
    @Default(0) int retryCount,
    @Default(true) bool isResumable,
    @Default(3) int priority,
  }) = _DownloadTask;

  factory DownloadTask.fromJson(Map<String, dynamic> json) =>
      _$DownloadTaskFromJson(json);
}
