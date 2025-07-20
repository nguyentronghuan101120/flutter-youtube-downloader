import 'dart:convert';
import '../../domain/entities/video_stream.dart';

/// Data model for video stream with JSON serialization
class VideoStreamModel extends VideoStream {
  const VideoStreamModel({
    required super.id,
    required super.url,
    required super.width,
    required super.height,
    required super.resolution,
    required super.bitrate,
    required super.codec,
    required super.format,
    super.fileSizeBytes,
    super.fileSizeFormatted,
    super.isAdaptive,
    super.fps,
    super.qualityLabel,
  });

  /// Create VideoStreamModel from VideoStream entity
  factory VideoStreamModel.fromEntity(VideoStream entity) {
    return VideoStreamModel(
      id: entity.id,
      url: entity.url,
      width: entity.width,
      height: entity.height,
      resolution: entity.resolution,
      bitrate: entity.bitrate,
      codec: entity.codec,
      format: entity.format,
      fileSizeBytes: entity.fileSizeBytes,
      fileSizeFormatted: entity.fileSizeFormatted,
      isAdaptive: entity.isAdaptive,
      fps: entity.fps,
      qualityLabel: entity.qualityLabel,
    );
  }

  /// Create VideoStreamModel from JSON map
  factory VideoStreamModel.fromJson(Map<String, dynamic> json) {
    return VideoStreamModel(
      id: json['id'] as String,
      url: json['url'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      resolution: json['resolution'] as String,
      bitrate: json['bitrate'] as int,
      codec: json['codec'] as String,
      format: json['format'] as String,
      fileSizeBytes: json['fileSizeBytes'] as int?,
      fileSizeFormatted: json['fileSizeFormatted'] as String?,
      isAdaptive: json['isAdaptive'] as bool? ?? false,
      fps: json['fps'] as String?,
      qualityLabel: json['qualityLabel'] as String?,
    );
  }

  /// Create VideoStreamModel from YouTube stream data
  factory VideoStreamModel.fromYouTubeStream(Map<String, dynamic> streamData) {
    final itag = streamData['itag']?.toString() ?? '';
    final url = streamData['url'] as String? ?? '';
    final mimeType = streamData['mimeType'] as String? ?? '';
    final quality = streamData['quality'] as String? ?? '';
    final qualityLabel = streamData['qualityLabel'] as String? ?? '';
    final width = streamData['width'] as int? ?? 0;
    final height = streamData['height'] as int? ?? 0;
    final bitrate = streamData['bitrate'] as int? ?? 0;
    final fps = streamData['fps']?.toString() ?? '';

    // Parse codec from mime type
    final codec = _extractCodecFromMimeType(mimeType);

    // Parse format from mime type
    final format = _extractFormatFromMimeType(mimeType);

    // Generate resolution string
    final resolution = width > 0 && height > 0 ? '${width}x$height' : quality;

    return VideoStreamModel(
      id: itag,
      url: url,
      width: width,
      height: height,
      resolution: resolution,
      bitrate: bitrate,
      codec: codec,
      format: format,
      isAdaptive: streamData['isAdaptive'] as bool? ?? false,
      fps: fps.isNotEmpty ? fps : null,
      qualityLabel: qualityLabel.isNotEmpty ? qualityLabel : null,
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
    if (mimeType.contains('video/mp4')) return 'H.264';
    if (mimeType.contains('video/webm')) return 'VP9';
    if (mimeType.contains('video/3gpp')) return 'H.263';

    return 'unknown';
  }

  /// Extract format from MIME type
  static String _extractFormatFromMimeType(String mimeType) {
    if (mimeType.contains('video/mp4')) return 'mp4';
    if (mimeType.contains('video/webm')) return 'webm';
    if (mimeType.contains('video/3gpp')) return '3gp';
    if (mimeType.contains('video/x-flv')) return 'flv';

    return 'unknown';
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'width': width,
      'height': height,
      'resolution': resolution,
      'bitrate': bitrate,
      'codec': codec,
      'format': format,
      'fileSizeBytes': fileSizeBytes,
      'fileSizeFormatted': fileSizeFormatted,
      'isAdaptive': isAdaptive,
      'fps': fps,
      'qualityLabel': qualityLabel,
    };
  }

  /// Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Create from JSON string
  factory VideoStreamModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return VideoStreamModel.fromJson(json);
  }

  /// Convert to VideoStream entity
  VideoStream toEntity() {
    return VideoStream(
      id: id,
      url: url,
      width: width,
      height: height,
      resolution: resolution,
      bitrate: bitrate,
      codec: codec,
      format: format,
      fileSizeBytes: fileSizeBytes,
      fileSizeFormatted: fileSizeFormatted,
      isAdaptive: isAdaptive,
      fps: fps,
      qualityLabel: qualityLabel,
    );
  }

  /// Create a copy with updated properties
  @override
  VideoStreamModel copyWith({
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
    return VideoStreamModel(
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
}
