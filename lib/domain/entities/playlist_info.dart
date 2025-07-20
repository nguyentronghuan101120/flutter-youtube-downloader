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
}
