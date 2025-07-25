import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/video_info.dart';

part 'video_analysis_state.freezed.dart';

enum VideoAnalysisStatus { initial, loading, success, error }

@freezed
class VideoAnalysisState with _$VideoAnalysisState {
  /// Creates initial state
  const factory VideoAnalysisState.initial() = _Initial;

  /// Creates loading state
  const factory VideoAnalysisState.loading({String? lastAnalyzedUrl}) =
      _Loading;

  /// Creates success state
  const factory VideoAnalysisState.success({
    required VideoInfo videoInfo,
    String? lastAnalyzedUrl,
  }) = _Success;

  /// Creates error state
  const factory VideoAnalysisState.error({
    required String errorMessage,
    String? lastAnalyzedUrl,
  }) = _Error;
}

// Extension để thêm các helper methods
extension VideoAnalysisStateUtils on VideoAnalysisState {
  /// Checks if the state is in initial state
  bool get isInitial => this is _Initial;

  /// Checks if the state is loading
  bool get isLoading => this is _Loading;

  /// Checks if the state is successful
  bool get isSuccess => this is _Success;

  /// Checks if the state has an error
  bool get isError => this is _Error;

  /// Checks if video info is available
  bool get hasVideoInfo => when(
    initial: () => false,
    loading: (_) => false,
    success: (_, __) => true,
    error: (_, __) => false,
  );

  /// Checks if there's an error message
  bool get hasError => when(
    initial: () => false,
    loading: (_) => false,
    success: (_, __) => false,
    error: (errorMessage, _) => errorMessage.isNotEmpty,
  );

  /// Gets video info if available
  VideoInfo? get videoInfo => when(
    initial: () => null,
    loading: (_) => null,
    success: (videoInfo, _) => videoInfo,
    error: (_, __) => null,
  );

  /// Gets error message if available
  String? get errorMessage => when(
    initial: () => null,
    loading: (_) => null,
    success: (_, __) => null,
    error: (errorMessage, _) => errorMessage,
  );

  /// Gets last analyzed URL
  String? get lastAnalyzedUrl => when(
    initial: () => null,
    loading: (lastAnalyzedUrl) => lastAnalyzedUrl,
    success: (_, lastAnalyzedUrl) => lastAnalyzedUrl,
    error: (_, lastAnalyzedUrl) => lastAnalyzedUrl,
  );
}
