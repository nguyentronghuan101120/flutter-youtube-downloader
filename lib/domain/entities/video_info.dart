import 'package:freezed_annotation/freezed_annotation.dart';
import 'video_format.dart';
import 'video_stream.dart';
import 'audio_stream.dart';
import 'subtitle_info.dart';

part 'video_info.freezed.dart';
part 'video_info.g.dart';

@freezed
class VideoInfo with _$VideoInfo {
  const factory VideoInfo({
    required String id,
    required String title,
    required String author,
    required Duration duration,
    required String thumbnailUrl,
    required List<VideoFormat> formats,
    @Default([]) List<VideoStream> videoStreams,
    @Default([]) List<AudioStream> audioStreams,
    @Default([]) List<SubtitleInfo> subtitles,
    @Default('') String description,
    @Default('') String url,
    DateTime? uploadDate,
    @Default(0) int viewCount,
    @Default([]) List<String> tags,
  }) = _VideoInfo;

  factory VideoInfo.fromJson(Map<String, dynamic> json) =>
      _$VideoInfoFromJson(json);
}
