import 'package:equatable/equatable.dart';
import 'video_info.dart';

enum DownloadStatus {
  queued,
  initializing,
  downloading,
  paused,
  converting,
  completed,
  failed,
  cancelled,
}

enum DownloadType { video, audio, subtitle }

class DownloadTask extends Equatable {
  final String id;
  final VideoInfo videoInfo;
  final DownloadType type;
  final String selectedFormat;
  final String selectedQuality;
  final String destinationPath;
  final DownloadStatus status;
  final double progress;
  final int downloadedBytes;
  final int totalBytes;
  final double downloadSpeed;
  final int estimatedTimeRemaining;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const DownloadTask({
    required this.id,
    required this.videoInfo,
    required this.type,
    required this.selectedFormat,
    required this.selectedQuality,
    required this.destinationPath,
    this.status = DownloadStatus.queued,
    this.progress = 0.0,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.downloadSpeed = 0.0,
    this.estimatedTimeRemaining = 0,
    this.errorMessage,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  DownloadTask copyWith({
    String? id,
    VideoInfo? videoInfo,
    DownloadType? type,
    String? selectedFormat,
    String? selectedQuality,
    String? destinationPath,
    DownloadStatus? status,
    double? progress,
    int? downloadedBytes,
    int? totalBytes,
    double? downloadSpeed,
    int? estimatedTimeRemaining,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return DownloadTask(
      id: id ?? this.id,
      videoInfo: videoInfo ?? this.videoInfo,
      type: type ?? this.type,
      selectedFormat: selectedFormat ?? this.selectedFormat,
      selectedQuality: selectedQuality ?? this.selectedQuality,
      destinationPath: destinationPath ?? this.destinationPath,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadSpeed: downloadSpeed ?? this.downloadSpeed,
      estimatedTimeRemaining:
          estimatedTimeRemaining ?? this.estimatedTimeRemaining,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    videoInfo,
    type,
    selectedFormat,
    selectedQuality,
    destinationPath,
    status,
    progress,
    downloadedBytes,
    totalBytes,
    downloadSpeed,
    estimatedTimeRemaining,
    errorMessage,
    createdAt,
    startedAt,
    completedAt,
  ];
}
