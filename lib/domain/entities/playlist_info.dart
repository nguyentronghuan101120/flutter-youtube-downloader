import 'package:equatable/equatable.dart';
import 'video_info.dart';

class PlaylistInfo extends Equatable {
  final String id;
  final String title;
  final String description;
  final String author;
  final String authorId;
  final int videoCount;
  final List<VideoInfo> videos;
  final String? thumbnailUrl;
  final bool isPrivate;
  final bool isUnlisted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? nextPageToken;
  final bool hasMoreVideos;

  const PlaylistInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.authorId,
    required this.videoCount,
    required this.videos,
    this.thumbnailUrl,
    this.isPrivate = false,
    this.isUnlisted = false,
    this.createdAt,
    this.updatedAt,
    this.nextPageToken,
    this.hasMoreVideos = false,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    author,
    authorId,
    videoCount,
    videos,
    thumbnailUrl,
    isPrivate,
    isUnlisted,
    createdAt,
    updatedAt,
    nextPageToken,
    hasMoreVideos,
  ];

  /// Create a copy with updated properties
  PlaylistInfo copyWith({
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
    return PlaylistInfo(
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
}
