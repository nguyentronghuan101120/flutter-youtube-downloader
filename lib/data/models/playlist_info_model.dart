import '../../domain/entities/playlist_info.dart';
import 'video_info_model.dart';

class PlaylistInfoModel extends PlaylistInfo {
  const PlaylistInfoModel({
    required super.id,
    required super.title,
    required super.description,
    required super.channelName,
    required super.channelId,
    required super.thumbnailUrl,
    required super.videoCount,
    required super.videos,
    super.isPrivate,
    super.isRegionBlocked,
  });

  factory PlaylistInfoModel.fromMap(Map<String, dynamic> map) {
    return PlaylistInfoModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      channelName: map['channelName'] ?? '',
      channelId: map['channelId'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      videoCount: map['videoCount'] ?? 0,
      videos: List<VideoInfoModel>.from(
        map['videos']?.map((x) => VideoInfoModel.fromMap(x)) ?? [],
      ),
      isPrivate: map['isPrivate'] ?? false,
      isRegionBlocked: map['isRegionBlocked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'channelName': channelName,
      'channelId': channelId,
      'thumbnailUrl': thumbnailUrl,
      'videoCount': videoCount,
      'videos': videos.map((x) => (x as VideoInfoModel).toMap()).toList(),
      'isPrivate': isPrivate,
      'isRegionBlocked': isRegionBlocked,
    };
  }
}
