import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/video_info.dart';
import '../../../domain/entities/video_stream.dart';
import '../../../domain/entities/audio_stream.dart';

part 'download_state.freezed.dart';

@freezed
class DownloadState with _$DownloadState {
  const factory DownloadState.initial() = _Initial;

  const factory DownloadState.loading() = _Loading;

  const factory DownloadState.ready({
    required VideoInfo videoInfo,
    required List<VideoStream> videoStreams,
    required List<AudioStream> audioStreams,
  }) = _Ready;

  const factory DownloadState.failed({required String message}) = _Failed;
}
