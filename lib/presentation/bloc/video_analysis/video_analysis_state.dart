part of 'video_analysis_cubit.dart';

abstract class VideoAnalysisState extends Equatable {
  const VideoAnalysisState();

  @override
  List<Object?> get props => [];
}

class VideoAnalysisInitial extends VideoAnalysisState {}

class VideoAnalysisLoading extends VideoAnalysisState {}

class VideoAnalysisSuccess extends VideoAnalysisState {
  final VideoInfo videoInfo;

  const VideoAnalysisSuccess(this.videoInfo);

  @override
  List<Object?> get props => [videoInfo];
}

class VideoAnalysisError extends VideoAnalysisState {
  final String message;

  const VideoAnalysisError(this.message);

  @override
  List<Object?> get props => [message];
}
