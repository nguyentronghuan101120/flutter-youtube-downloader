import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_stream.freezed.dart';
part 'video_stream.g.dart';

@freezed
class VideoStream with _$VideoStream {
  const factory VideoStream({
    required String url,
    required String format,
    required String quality,
    required int width,
    required int height,
    required int bitrate,
    required int fileSize,
    required String codec,
  }) = _VideoStream;

  factory VideoStream.fromJson(Map<String, dynamic> json) =>
      _$VideoStreamFromJson(json);
}
