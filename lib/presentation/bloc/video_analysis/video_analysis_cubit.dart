import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/analyze_video.dart';
import '../../../core/error/failures.dart';
import 'video_analysis_state.dart';

class VideoAnalysisCubit extends Cubit<VideoAnalysisState> {
  final AnalyzeVideo _analyzeVideo;

  VideoAnalysisCubit({required AnalyzeVideo analyzeVideo})
    : _analyzeVideo = analyzeVideo,
      super(VideoAnalysisInitial());

  Future<void> analyzeVideo(String url) async {
    emit(VideoAnalysisLoading());

    final result = await _analyzeVideo(url);

    result.fold(
      (failure) {
        String message;
        if (failure is InvalidInputFailure) {
          message = 'Invalid YouTube URL. Please check the URL and try again.';
        } else if (failure is ServerFailure) {
          message = 'Failed to analyze video. Please try again later.';
        } else if (failure is VideoNotFoundFailure) {
          message = 'Video not found or is private.';
        } else {
          message = 'An unexpected error occurred.';
        }
        emit(VideoAnalysisError(message: message));
      },
      (videoInfo) {
        emit(VideoAnalysisLoaded(videoInfo: videoInfo));
      },
    );
  }

  void reset() {
    emit(VideoAnalysisInitial());
  }
}
