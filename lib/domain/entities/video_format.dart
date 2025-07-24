import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_format.freezed.dart';
part 'video_format.g.dart';

@freezed
class VideoFormat with _$VideoFormat {
  const factory VideoFormat({
    required String format,
    required String quality,
    required int bitrate,
    required int fileSize,
    required String mimeType,
    required bool isAudioOnly,
  }) = _VideoFormat;

  factory VideoFormat.fromJson(Map<String, dynamic> json) =>
      _$VideoFormatFromJson(json);
}
