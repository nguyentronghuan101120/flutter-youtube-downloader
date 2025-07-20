part of 'video_analysis_cubit.dart';

abstract class VideoAnalysisState extends Equatable {
  const VideoAnalysisState();

  @override
  List<Object?> get props => [];
}

class VideoAnalysisInitial extends VideoAnalysisState {}

class VideoAnalysisLoading extends VideoAnalysisState {
  final double? progress;
  final String? lastUrl;

  const VideoAnalysisLoading({this.progress, this.lastUrl});

  @override
  List<Object?> get props => [progress, lastUrl];
}

class VideoAnalysisSuccess extends VideoAnalysisState {
  final VideoInfo videoInfo;
  final String? lastUrl;
  final DownloadType downloadType;
  final String selectedFormat;
  final String selectedQuality;

  const VideoAnalysisSuccess(
    this.videoInfo, {
    this.lastUrl,
    this.downloadType = DownloadType.videoOnly,
    this.selectedFormat = 'MP4',
    this.selectedQuality = '1080p',
  });

  @override
  List<Object?> get props => [
    videoInfo,
    lastUrl,
    downloadType,
    selectedFormat,
    selectedQuality,
  ];
}

class VideoAnalysisError extends VideoAnalysisState {
  final String message;
  final String? lastUrl;

  const VideoAnalysisError(this.message, {this.lastUrl});

  @override
  List<Object?> get props => [message, lastUrl];
}
