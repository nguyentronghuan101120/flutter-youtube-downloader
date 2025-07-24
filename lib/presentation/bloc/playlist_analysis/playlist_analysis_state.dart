import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/playlist_info.dart';

part 'playlist_analysis_state.freezed.dart';

enum PlaylistAnalysisStatus { initial, loading, success, error }

@freezed
class PlaylistAnalysisState with _$PlaylistAnalysisState {
  /// Creates initial state
  const factory PlaylistAnalysisState.initial() = _Initial;

  /// Creates loading state
  const factory PlaylistAnalysisState.loading({
    String? lastAnalyzedUrl,
    int? processedCount,
    int? totalCount,
  }) = _Loading;

  /// Creates success state
  const factory PlaylistAnalysisState.success({
    required PlaylistInfo playlistInfo,
    String? lastAnalyzedUrl,
  }) = _Success;

  /// Creates error state
  const factory PlaylistAnalysisState.error({
    required String errorMessage,
    String? lastAnalyzedUrl,
  }) = _Error;
}

// Extension để thêm các helper methods
extension PlaylistAnalysisStateUtils on PlaylistAnalysisState {
  /// Checks if the state is in initial state
  bool get isInitial => this is _Initial;

  /// Checks if the state is loading
  bool get isLoading => this is _Loading;

  /// Checks if the state is successful
  bool get isSuccess => this is _Success;

  /// Checks if the state has an error
  bool get isError => this is _Error;

  /// Checks if playlist info is available
  bool get hasPlaylistInfo => when(
    initial: () => false,
    loading: (_, __, ___) => false,
    success: (_, __) => true,
    error: (_, __) => false,
  );

  /// Checks if there's an error message
  bool get hasError => when(
    initial: () => false,
    loading: (_, __, ___) => false,
    success: (_, __) => false,
    error: (errorMessage, _) => errorMessage.isNotEmpty,
  );

  /// Gets playlist info if available
  PlaylistInfo? get playlistInfo => when(
    initial: () => null,
    loading: (_, __, ___) => null,
    success: (playlistInfo, _) => playlistInfo,
    error: (_, __) => null,
  );

  /// Gets error message if available
  String? get errorMessage => when(
    initial: () => null,
    loading: (_, __, ___) => null,
    success: (_, __) => null,
    error: (errorMessage, _) => errorMessage,
  );

  /// Gets last analyzed URL
  String? get lastAnalyzedUrl => when(
    initial: () => null,
    loading: (lastAnalyzedUrl, _, __) => lastAnalyzedUrl,
    success: (_, lastAnalyzedUrl) => lastAnalyzedUrl,
    error: (_, lastAnalyzedUrl) => lastAnalyzedUrl,
  );

  /// Gets progress information for loading state
  ({int processed, int total})? get progress => when(
    initial: () => null,
    loading: (_, processedCount, totalCount) =>
        (processed: processedCount ?? 0, total: totalCount ?? 0),
    success: (_, __) => null,
    error: (_, __) => null,
  );
}
