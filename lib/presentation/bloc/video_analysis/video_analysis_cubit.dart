import 'package:injectable/injectable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/analyze_video.dart';
import 'video_analysis_state.dart';

@injectable
class VideoAnalysisCubit extends Cubit<VideoAnalysisState> {
  final AnalyzeVideoUseCase _analyzeVideoUseCase;

  VideoAnalysisCubit({required AnalyzeVideoUseCase analyzeVideoUseCase})
    : _analyzeVideoUseCase = analyzeVideoUseCase,
      super(const VideoAnalysisState.initial());

  /// Analyzes a YouTube video URL
  ///
  /// [url] - The YouTube video URL to analyze
  Future<void> analyzeVideo(String url) async {
    try {
      // Emit loading state
      emit(VideoAnalysisState.loading(lastAnalyzedUrl: url));

      // Validate URL first
      if (!_analyzeVideoUseCase.isValidVideoUrl(url)) {
        emit(
          VideoAnalysisState.error(
            errorMessage: 'Invalid YouTube video URL format',
            lastAnalyzedUrl: url,
          ),
        );
        return;
      }

      // Extract video ID for additional validation
      final videoId = _analyzeVideoUseCase.extractVideoId(url);
      if (videoId == null) {
        emit(
          VideoAnalysisState.error(
            errorMessage: 'Could not extract video ID from URL',
            lastAnalyzedUrl: url,
          ),
        );
        return;
      }

      // Analyze video using use case
      final videoInfo = await _analyzeVideoUseCase.execute(url);

      // Emit success state
      emit(
        VideoAnalysisState.success(videoInfo: videoInfo, lastAnalyzedUrl: url),
      );
    } catch (e) {
      // Emit error state
      emit(
        VideoAnalysisState.error(
          errorMessage: e.toString(),
          lastAnalyzedUrl: url,
        ),
      );
    }
  }

  /// Validates a URL without analyzing
  ///
  /// [url] - The URL to validate
  /// Returns true if URL is valid, false otherwise
  bool validateUrl(String url) {
    return _analyzeVideoUseCase.isValidVideoUrl(url);
  }

  /// Extracts video ID from URL
  ///
  /// [url] - The URL to extract ID from
  /// Returns video ID if found, null otherwise
  String? extractVideoId(String url) {
    return _analyzeVideoUseCase.extractVideoId(url);
  }

  /// Resets the state to initial
  void reset() {
    emit(const VideoAnalysisState.initial());
  }

  /// Clears the error message
  void clearError() {
    final currentState = state;
    if (currentState.isSuccess) {
      // Keep the current success state
      return;
    } else {
      emit(const VideoAnalysisState.initial());
    }
  }

  /// Retries the last analysis
  Future<void> retry() async {
    final currentState = state;
    final lastUrl = currentState.lastAnalyzedUrl;
    if (lastUrl != null) {
      await analyzeVideo(lastUrl);
    }
  }
}
