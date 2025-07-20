import 'dart:convert';
import '../../domain/entities/audio_stream.dart';

/// Data model for audio stream with JSON serialization
class AudioStreamModel extends AudioStream {
  const AudioStreamModel({
    required super.id,
    required super.url,
    required super.bitrate,
    required super.sampleRate,
    required super.channels,
    required super.codec,
    required super.format,
    super.fileSizeBytes,
    super.fileSizeFormatted,
    super.isAdaptive,
    super.qualityLabel,
    super.language,
  });

  /// Create AudioStreamModel from AudioStream entity
  factory AudioStreamModel.fromEntity(AudioStream entity) {
    return AudioStreamModel(
      id: entity.id,
      url: entity.url,
      bitrate: entity.bitrate,
      sampleRate: entity.sampleRate,
      channels: entity.channels,
      codec: entity.codec,
      format: entity.format,
      fileSizeBytes: entity.fileSizeBytes,
      fileSizeFormatted: entity.fileSizeFormatted,
      isAdaptive: entity.isAdaptive,
      qualityLabel: entity.qualityLabel,
      language: entity.language,
    );
  }

  /// Create AudioStreamModel from JSON map
  factory AudioStreamModel.fromJson(Map<String, dynamic> json) {
    return AudioStreamModel(
      id: json['id'] as String,
      url: json['url'] as String,
      bitrate: json['bitrate'] as int,
      sampleRate: json['sampleRate'] as int,
      channels: json['channels'] as int,
      codec: json['codec'] as String,
      format: json['format'] as String,
      fileSizeBytes: json['fileSizeBytes'] as int?,
      fileSizeFormatted: json['fileSizeFormatted'] as String?,
      isAdaptive: json['isAdaptive'] as bool? ?? false,
      qualityLabel: json['qualityLabel'] as String?,
      language: json['language'] as String?,
    );
  }

  /// Create AudioStreamModel from YouTube audio stream data
  factory AudioStreamModel.fromYouTubeStream(Map<String, dynamic> streamData) {
    final itag = streamData['itag']?.toString() ?? '';
    final url = streamData['url'] as String? ?? '';
    final mimeType = streamData['mimeType'] as String? ?? '';
    final bitrate = streamData['bitrate'] as int? ?? 0;
    final qualityLabel = streamData['qualityLabel'] as String? ?? '';
    final language = streamData['language'] as String?;

    // Parse codec from mime type
    final codec = _extractCodecFromMimeType(mimeType);

    // Parse format from mime type
    final format = _extractFormatFromMimeType(mimeType);

    // Extract sample rate and channels from mime type or use defaults
    final sampleRate = _extractSampleRateFromMimeType(mimeType);
    final channels = _extractChannelsFromMimeType(mimeType);

    return AudioStreamModel(
      id: itag,
      url: url,
      bitrate: bitrate,
      sampleRate: sampleRate,
      channels: channels,
      codec: codec,
      format: format,
      isAdaptive: streamData['isAdaptive'] as bool? ?? false,
      qualityLabel: qualityLabel.isNotEmpty ? qualityLabel : null,
      language: language,
    );
  }

  /// Extract codec from MIME type
  static String _extractCodecFromMimeType(String mimeType) {
    if (mimeType.contains('codecs=')) {
      final codecMatch = RegExp(r'codecs="([^"]+)"').firstMatch(mimeType);
      if (codecMatch != null) {
        return codecMatch.group(1) ?? 'unknown';
      }
    }

    // Fallback codec detection
    if (mimeType.contains('audio/mp4')) return 'AAC';
    if (mimeType.contains('audio/webm')) return 'Opus';
    if (mimeType.contains('audio/mpeg')) return 'MP3';
    if (mimeType.contains('audio/ogg')) return 'Vorbis';

    return 'unknown';
  }

  /// Extract format from MIME type
  static String _extractFormatFromMimeType(String mimeType) {
    if (mimeType.contains('audio/mp4')) return 'aac';
    if (mimeType.contains('audio/webm')) return 'opus';
    if (mimeType.contains('audio/mpeg')) return 'mp3';
    if (mimeType.contains('audio/ogg')) return 'ogg';
    if (mimeType.contains('audio/wav')) return 'wav';
    if (mimeType.contains('audio/flac')) return 'flac';

    return 'unknown';
  }

  /// Extract sample rate from MIME type
  static int _extractSampleRateFromMimeType(String mimeType) {
    // Default sample rates for common audio formats
    if (mimeType.contains('audio/mp4') || mimeType.contains('audio/mpeg')) {
      return 44100; // Standard for MP3/AAC
    }
    if (mimeType.contains('audio/webm')) {
      return 48000; // Standard for Opus
    }
    if (mimeType.contains('audio/ogg')) {
      return 44100; // Standard for Vorbis
    }

    return 44100; // Default fallback
  }

  /// Extract channels from MIME type
  static int _extractChannelsFromMimeType(String mimeType) {
    // Most audio streams are stereo
    return 2;
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'bitrate': bitrate,
      'sampleRate': sampleRate,
      'channels': channels,
      'codec': codec,
      'format': format,
      'fileSizeBytes': fileSizeBytes,
      'fileSizeFormatted': fileSizeFormatted,
      'isAdaptive': isAdaptive,
      'qualityLabel': qualityLabel,
      'language': language,
    };
  }

  /// Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Create from JSON string
  factory AudioStreamModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return AudioStreamModel.fromJson(json);
  }

  /// Convert to AudioStream entity
  AudioStream toEntity() {
    return AudioStream(
      id: id,
      url: url,
      bitrate: bitrate,
      sampleRate: sampleRate,
      channels: channels,
      codec: codec,
      format: format,
      fileSizeBytes: fileSizeBytes,
      fileSizeFormatted: fileSizeFormatted,
      isAdaptive: isAdaptive,
      qualityLabel: qualityLabel,
      language: language,
    );
  }

  /// Create a copy with updated properties
  @override
  AudioStreamModel copyWith({
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
    return AudioStreamModel(
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
}
