import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_path_state.freezed.dart';

@freezed
class DownloadPathState with _$DownloadPathState {
  const factory DownloadPathState.initial() = _Initial;
  const factory DownloadPathState.loading() = _Loading;
  const factory DownloadPathState.loaded({
    required String path,
    String? systemDownloadsPath,
  }) = _Loaded;
  const factory DownloadPathState.error({required String message}) = _Error;
}
