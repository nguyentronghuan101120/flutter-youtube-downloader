import '../../domain/entities/playlist_info.dart';

// PlaylistInfoModel giờ chỉ là alias cho PlaylistInfo vì entity đã có freezed
typedef PlaylistInfoModel = PlaylistInfo;

// Extension để thêm các helper methods cho PlaylistInfoModel
extension PlaylistInfoModelUtils on PlaylistInfoModel {
  /// Creates PlaylistInfoModel from JSON map
  static PlaylistInfoModel fromMap(Map<String, dynamic> map) {
    return PlaylistInfoModel.fromJson(map);
  }

  /// Converts PlaylistInfoModel to JSON map
  Map<String, dynamic> toMap() {
    return toJson();
  }

  /// Creates PlaylistInfoModel from PlaylistInfo entity
  static PlaylistInfoModel fromEntity(PlaylistInfo entity) {
    return entity;
  }

  /// Converts PlaylistInfoModel to PlaylistInfo entity
  PlaylistInfo toEntity() {
    return this;
  }
}
