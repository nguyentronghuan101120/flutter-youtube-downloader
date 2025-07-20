import 'package:equatable/equatable.dart';

/// Entity representing an audio stream with quality information
class AudioStream extends Equatable {
  final String id;
  final String url;
  final int bitrate;
  final int sampleRate;
  final int channels;
  final String codec;
  final String format;
  final int? fileSizeBytes;
  final String? fileSizeFormatted;
  final bool isAdaptive;
  final String? qualityLabel;
  final String? language;

  const AudioStream({
    required this.id,
    required this.url,
    required this.bitrate,
    required this.sampleRate,
    required this.channels,
    required this.codec,
    required this.format,
    this.fileSizeBytes,
    this.fileSizeFormatted,
    this.isAdaptive = false,
    this.qualityLabel,
    this.language,
  });

  /// Get formatted bitrate
  String get formattedBitrate {
    if (bitrate >= 1000000) {
      return '${(bitrate / 1000000).toStringAsFixed(1)} Mbps';
    } else if (bitrate >= 1000) {
      return '${(bitrate / 1000).toStringAsFixed(1)} Kbps';
    }
    return '$bitrate bps';
  }

  /// Get formatted sample rate
  String get formattedSampleRate {
    if (sampleRate >= 1000) {
      return '${(sampleRate / 1000).toStringAsFixed(1)} kHz';
    }
    return '$sampleRate Hz';
  }

  /// Get channel configuration string
  String get channelConfig {
    switch (channels) {
      case 1:
        return 'Mono';
      case 2:
        return 'Stereo';
      case 6:
        return '5.1 Surround';
      case 8:
        return '7.1 Surround';
      default:
        return '$channels Channel';
    }
  }

  /// Get audio quality level based on bitrate
  String get qualityLevel {
    if (bitrate >= 320000) return 'High Quality';
    if (bitrate >= 256000) return 'Very Good';
    if (bitrate >= 192000) return 'Good';
    if (bitrate >= 128000) return 'Standard';
    if (bitrate >= 96000) return 'Low';
    return 'Very Low';
  }

  /// Get supported format extension
  String get fileExtension {
    switch (format.toLowerCase()) {
      case 'mp3':
        return 'mp3';
      case 'aac':
        return 'aac';
      case 'ogg':
        return 'ogg';
      case 'opus':
        return 'opus';
      case 'wav':
        return 'wav';
      case 'flac':
        return 'flac';
      default:
        return 'audio';
    }
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

  /// Check if format is supported
  bool get isSupported {
    const supportedFormats = ['mp3', 'aac', 'ogg', 'opus', 'wav', 'flac'];
    return supportedFormats.contains(format.toLowerCase());
  }

  /// Get display name for the stream
  String get displayName {
    final quality = qualityLevel;
    final format = this.format.toUpperCase();
    final bitrate = formattedBitrate;
    return '$quality $format ($bitrate)';
  }

  /// Create a copy with updated properties
  AudioStream copyWith({
    String? id,
    String? url,
    int? bitrate,
    int? sampleRate,
    int? channels,
    String? codec,
    String? format,
    int? fileSizeBytes,
    String? fileSizeFormatted,
    bool? isAdaptive,
    String? qualityLabel,
    String? language,
  }) {
    return AudioStream(
      id: id ?? this.id,
      url: url ?? this.url,
      bitrate: bitrate ?? this.bitrate,
      sampleRate: sampleRate ?? this.sampleRate,
      channels: channels ?? this.channels,
      codec: codec ?? this.codec,
      format: format ?? this.format,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      fileSizeFormatted: fileSizeFormatted ?? this.fileSizeFormatted,
      isAdaptive: isAdaptive ?? this.isAdaptive,
      qualityLabel: qualityLabel ?? this.qualityLabel,
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props => [
    id,
    url,
    bitrate,
    sampleRate,
    channels,
    codec,
    format,
    fileSizeBytes,
    fileSizeFormatted,
    isAdaptive,
    qualityLabel,
    language,
  ];

  @override
  String toString() {
    return 'AudioStream(id: $id, bitrate: $bitrate, format: $format, codec: $codec)';
  }
}
