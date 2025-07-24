import 'package:freezed_annotation/freezed_annotation.dart';
import 'video_info.dart';

part 'playlist_info.freezed.dart';
part 'playlist_info.g.dart';

@freezed
class PlaylistInfo with _$PlaylistInfo {
  const factory PlaylistInfo({
    required String id,
    required String title,
    required String description,
    required String channelName,
    required String channelId,
    required String thumbnailUrl,
    required int videoCount,
    required List<VideoInfo> videos,
    @Default(false) bool isPrivate,
    @Default(false) bool isRegionBlocked,
  }) = _PlaylistInfo;

  factory PlaylistInfo.fromJson(Map<String, dynamic> json) =>
      _$PlaylistInfoFromJson(json);
}
