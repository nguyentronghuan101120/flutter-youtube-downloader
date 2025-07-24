import '../../domain/entities/video_info.dart';

// VideoInfoModel giờ chỉ là alias cho VideoInfo vì entity đã có freezed
typedef VideoInfoModel = VideoInfo;

// Extension để thêm các helper methods cho VideoInfoModel
extension VideoInfoModelUtils on VideoInfoModel {
  /// Creates VideoInfoModel from JSON map
  static VideoInfoModel fromMap(Map<String, dynamic> map) {
    return VideoInfoModel.fromJson(map);
  }

  /// Converts VideoInfoModel to JSON map
  Map<String, dynamic> toMap() {
    return toJson();
  }

  /// Creates VideoInfoModel from VideoInfo entity
  static VideoInfoModel fromEntity(VideoInfo entity) {
    return entity;
  }

  /// Converts VideoInfoModel to VideoInfo entity
  VideoInfo toEntity() {
    return this;
  }

  /// Validates if the model data is valid
  bool isValid() {
    return id.isNotEmpty &&
        title.isNotEmpty &&
        author.isNotEmpty &&
        thumbnailUrl.isNotEmpty &&
        url.isNotEmpty;
  }

  /// Gets formatted duration string
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Gets formatted view count
  String get formattedViewCount {
    if (viewCount < 1000) {
      return viewCount.toString();
    } else if (viewCount < 1000000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K';
    } else if (viewCount < 1000000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M';
    } else {
      return '${(viewCount / 1000000000).toStringAsFixed(1)}B';
    }
  }

  /// Gets formatted upload date
  String get formattedUploadDate {
    final now = DateTime.now();
    final difference = now.difference(uploadDate);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

// Các model classes khác cũng đơn giản hóa
typedef VideoStreamModel = VideoStream;
typedef AudioStreamModel = AudioStream;
typedef SubtitleInfoModel = SubtitleInfo;
