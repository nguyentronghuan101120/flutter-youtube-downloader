import '../../domain/entities/playlist_info.dart';
import '../../domain/entities/video_info.dart';
import 'video_info_model.dart';

class PlaylistInfoModel extends PlaylistInfo {
  const PlaylistInfoModel({
    required super.id,
    required super.title,
    required super.description,
    required super.author,
    required super.authorId,
    required super.videoCount,
    required super.videos,
    super.thumbnailUrl,
    super.isPrivate,
    super.isUnlisted,
    super.createdAt,
    super.updatedAt,
    super.nextPageToken,
    super.hasMoreVideos,
  });

  factory PlaylistInfoModel.fromMap(Map<String, dynamic> map) {
    return PlaylistInfoModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      author: map['author'] ?? '',
      authorId: map['authorId'] ?? '',
      videoCount: map['videoCount'] ?? 0,
      videos: List<VideoInfoModel>.from(
        map['videos']?.map((x) => VideoInfoModel.fromMap(x)) ?? [],
      ),
      thumbnailUrl: map['thumbnailUrl'],
      isPrivate: map['isPrivate'] ?? false,
      isUnlisted: map['isUnlisted'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
      nextPageToken: map['nextPageToken'],
      hasMoreVideos: map['hasMoreVideos'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author': author,
      'authorId': authorId,
      'videoCount': videoCount,
      'videos': videos.map((x) => (x as VideoInfoModel).toMap()).toList(),
      'thumbnailUrl': thumbnailUrl,
      'isPrivate': isPrivate,
      'isUnlisted': isUnlisted,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'nextPageToken': nextPageToken,
      'hasMoreVideos': hasMoreVideos,
    };
  }

  /// Creates a copy of this model with updated pagination info
  PlaylistInfoModel copyWith({
    String? id,
    String? title,
    String? description,
    String? author,
    String? authorId,
    int? videoCount,
    List<VideoInfo>? videos,
    String? thumbnailUrl,
    bool? isPrivate,
    bool? isUnlisted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? nextPageToken,
    bool? hasMoreVideos,
  }) {
    return PlaylistInfoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      author: author ?? this.author,
      authorId: authorId ?? this.authorId,
      videoCount: videoCount ?? this.videoCount,
      videos: videos ?? this.videos,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isPrivate: isPrivate ?? this.isPrivate,
      isUnlisted: isUnlisted ?? this.isUnlisted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nextPageToken: nextPageToken ?? this.nextPageToken,
      hasMoreVideos: hasMoreVideos ?? this.hasMoreVideos,
    );
  }

  /// Adds more videos to the existing playlist
  PlaylistInfoModel addVideos(
    List<VideoInfo> newVideos, {
    String? nextPageToken,
    bool? hasMoreVideos,
  }) {
    final updatedVideos = List<VideoInfo>.from(videos)..addAll(newVideos);

    return copyWith(
      videos: updatedVideos,
      nextPageToken: nextPageToken,
      hasMoreVideos: hasMoreVideos,
    );
  }
}
