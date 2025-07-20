import 'package:equatable/equatable.dart';
import '../../../domain/entities/video_info.dart';

abstract class VideoAnalysisState extends Equatable {
  const VideoAnalysisState();

  @override
  List<Object?> get props => [];
}

class VideoAnalysisInitial extends VideoAnalysisState {}

class VideoAnalysisLoading extends VideoAnalysisState {}

class VideoAnalysisLoaded extends VideoAnalysisState {
  final VideoInfo videoInfo;

  const VideoAnalysisLoaded({required this.videoInfo});

  @override
  List<Object?> get props => [videoInfo];
}

class VideoAnalysisError extends VideoAnalysisState {
  final String message;

  const VideoAnalysisError({required this.message});

  @override
  List<Object?> get props => [message];
}
