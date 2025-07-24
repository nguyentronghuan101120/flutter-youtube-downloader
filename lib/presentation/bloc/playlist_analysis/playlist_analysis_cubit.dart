import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/playlist_info.dart';
import '../../../domain/usecases/analyze_playlist.dart';
import '../../../core/result/result.dart';
import 'playlist_analysis_state.dart';

@injectable
class PlaylistAnalysisCubit extends Cubit<PlaylistAnalysisState> {
  final AnalyzePlaylistUseCase _analyzePlaylistUseCase;

  PlaylistAnalysisCubit({
    required AnalyzePlaylistUseCase analyzePlaylistUseCase,
  }) : _analyzePlaylistUseCase = analyzePlaylistUseCase,
       super(const PlaylistAnalysisState.initial());

  /// Analyzes a YouTube playlist URL
  ///
  /// [url] - The YouTube playlist URL to analyze
  Future<void> analyzePlaylist(String url) async {
    try {
      // Emit loading state
      emit(PlaylistAnalysisState.loading(lastAnalyzedUrl: url));

      // Analyze playlist using use case
      final result = await _analyzePlaylistUseCase.execute(url);

      if (result.isSuccess) {
        final videos = result.data!;

        // Create PlaylistInfo from videos (simplified for now)
        // In a real implementation, you would get full playlist info from the service
        final playlistInfo = PlaylistInfo(
          id: 'playlist_id', // Would be set from actual playlist data
          title: 'Playlist', // Would be set from actual playlist data
          description: 'Playlist with ${videos.length} videos',
          channelName:
              'Unknown Channel', // Would be set from actual playlist data
          channelId: '',
          thumbnailUrl: videos.isNotEmpty ? videos.first.thumbnailUrl : '',
          videoCount: videos.length,
          videos: videos,
          isPrivate: false,
          isRegionBlocked: false,
        );

        // Emit success state
        emit(
          PlaylistAnalysisState.success(
            playlistInfo: playlistInfo,
            lastAnalyzedUrl: url,
          ),
        );
      } else {
        // Emit error state
        emit(
          PlaylistAnalysisState.error(
            errorMessage: result.errorMessage!,
            lastAnalyzedUrl: url,
          ),
        );
      }
    } catch (e) {
      // Emit error state
      emit(
        PlaylistAnalysisState.error(
          errorMessage: e.toString(),
          lastAnalyzedUrl: url,
        ),
      );
    }
  }

  /// Resets the state to initial
  void reset() {
    emit(const PlaylistAnalysisState.initial());
  }

  /// Clears the error message
  void clearError() {
    final currentState = state;
    if (currentState.isSuccess) {
      // Keep the current success state
      return;
    } else {
      emit(const PlaylistAnalysisState.initial());
    }
  }

  /// Retries the last analysis
  Future<void> retry() async {
    final currentState = state;
    final lastUrl = currentState.lastAnalyzedUrl;
    if (lastUrl != null) {
      await analyzePlaylist(lastUrl);
    }
  }
}
