import 'package:equatable/equatable.dart';
import 'video_info.dart';

class PlaylistInfo extends Equatable {
  final String id;
  final String title;
  final String description;
  final String channelName;
  final String channelId;
  final String thumbnailUrl;
  final int videoCount;
  final List<VideoInfo> videos;
  final bool isPrivate;
  final bool isRegionBlocked;

  const PlaylistInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.channelName,
    required this.channelId,
    required this.thumbnailUrl,
    required this.videoCount,
    required this.videos,
    this.isPrivate = false,
    this.isRegionBlocked = false,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    channelName,
    channelId,
    thumbnailUrl,
    videoCount,
    videos,
    isPrivate,
    isRegionBlocked,
  ];
}
