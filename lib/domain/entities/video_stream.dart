import 'package:equatable/equatable.dart';

/// Entity representing a video stream with quality information
class VideoStream extends Equatable {
  final String id;
  final String url;
  final int width;
  final int height;
  final String resolution;
  final int bitrate;
  final String codec;
  final String format;
  final int? fileSizeBytes;
  final String? fileSizeFormatted;
  final bool isAdaptive;
  final String? fps;
  final String? qualityLabel;

  const VideoStream({
    required this.id,
    required this.url,
    required this.width,
    required this.height,
    required this.resolution,
    required this.bitrate,
    required this.codec,
    required this.format,
    this.fileSizeBytes,
    this.fileSizeFormatted,
    this.isAdaptive = false,
    this.fps,
    this.qualityLabel,
  });

  /// Get display resolution string
  String get displayResolution => '${width}x$height';

  /// Get quality level based on resolution
  String get qualityLevel {
    if (height >= 2160) return '4K';
    if (height >= 1440) return '2K';
    if (height >= 1080) return '1080p';
    if (height >= 720) return '720p';
    if (height >= 480) return '480p';
    if (height >= 360) return '360p';
    if (height >= 240) return '240p';
    return '144p';
  }

  /// Get formatted bitrate
  String get formattedBitrate {
    if (bitrate >= 1000000) {
      return '${(bitrate / 1000000).toStringAsFixed(1)} Mbps';
    } else if (bitrate >= 1000) {
      return '${(bitrate / 1000).toStringAsFixed(1)} Kbps';
    }
    return '$bitrate bps';
  }

  /// Estimate file size for given duration in seconds
  int estimateFileSize(int durationSeconds) {
    // Basic estimation: bitrate * duration / 8 (bits to bytes)
    return (bitrate * durationSeconds) ~/ 8;
  }

  /// Get formatted file size for given duration
  String getFormattedFileSize(int durationSeconds) {
    final sizeBytes = estimateFileSize(durationSeconds);
    return _formatFileSize(sizeBytes);
  }

  /// Format file size in human readable format
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Create a copy with updated properties
  VideoStream copyWith({
    String? id,
    String? url,
    int? width,
    int? height,
    String? resolution,
    int? bitrate,
    String? codec,
    String? format,
    int? fileSizeBytes,
    String? fileSizeFormatted,
    bool? isAdaptive,
    String? fps,
    String? qualityLabel,
  }) {
    return VideoStream(
      id: id ?? this.id,
      url: url ?? this.url,
      width: width ?? this.width,
      height: height ?? this.height,
      resolution: resolution ?? this.resolution,
      bitrate: bitrate ?? this.bitrate,
      codec: codec ?? this.codec,
      format: format ?? this.format,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      fileSizeFormatted: fileSizeFormatted ?? this.fileSizeFormatted,
      isAdaptive: isAdaptive ?? this.isAdaptive,
      fps: fps ?? this.fps,
      qualityLabel: qualityLabel ?? this.qualityLabel,
    );
  }

  @override
  List<Object?> get props => [
    id,
    url,
    width,
    height,
    resolution,
    bitrate,
    codec,
    format,
    fileSizeBytes,
    fileSizeFormatted,
    isAdaptive,
    fps,
    qualityLabel,
  ];

  @override
  String toString() {
    return 'VideoStream(id: $id, resolution: $resolution, bitrate: $bitrate, codec: $codec)';
  }
}
