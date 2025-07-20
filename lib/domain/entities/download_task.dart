import 'package:equatable/equatable.dart';

enum DownloadStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

enum DownloadType { video, audio, subtitle }

class DownloadTask extends Equatable {
  final String id;
  final String videoId;
  final String title;
  final String formatId;
  final String outputPath;
  final DownloadStatus status;
  final int bytesDownloaded;
  final int totalBytes;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;

  const DownloadTask({
    required this.id,
    required this.videoId,
    required this.title,
    required this.formatId,
    required this.outputPath,
    this.status = DownloadStatus.pending,
    this.bytesDownloaded = 0,
    this.totalBytes = 0,
    this.errorMessage,
    required this.createdAt,
    this.completedAt,
  });

  double get progress {
    if (totalBytes == 0) return 0.0;
    return bytesDownloaded / totalBytes;
  }

  bool get isCompleted => status == DownloadStatus.completed;
  bool get isFailed => status == DownloadStatus.failed;
  bool get isDownloading => status == DownloadStatus.downloading;

  DownloadTask copyWith({
    String? id,
    String? videoId,
    String? title,
    String? formatId,
    String? outputPath,
    DownloadStatus? status,
    int? bytesDownloaded,
    int? totalBytes,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return DownloadTask(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      formatId: formatId ?? this.formatId,
      outputPath: outputPath ?? this.outputPath,
      status: status ?? this.status,
      bytesDownloaded: bytesDownloaded ?? this.bytesDownloaded,
      totalBytes: totalBytes ?? this.totalBytes,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    videoId,
    title,
    formatId,
    outputPath,
    status,
    bytesDownloaded,
    totalBytes,
    errorMessage,
    createdAt,
    completedAt,
  ];
}
