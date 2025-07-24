import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/analyze_video.dart';
import '../../../core/result/result.dart';
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

      // Analyze video using use case
      final result = await _analyzeVideoUseCase.execute(url);

      if (result.isSuccess) {
        // Emit success state
        emit(
          VideoAnalysisState.success(
            videoInfo: result.data!,
            lastAnalyzedUrl: url,
          ),
        );
      } else {
        // Emit error state
        emit(
          VideoAnalysisState.error(
            errorMessage: result.errorMessage!,
            lastAnalyzedUrl: url,
          ),
        );
      }
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
