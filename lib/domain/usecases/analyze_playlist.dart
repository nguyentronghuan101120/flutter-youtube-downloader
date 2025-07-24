import 'package:injectable/injectable.dart';
import '../entities/video_info.dart';
import '../repositories/video_repository.dart';
import '../../core/usecases/base_usecase.dart';
import '../../core/result/result.dart';

@injectable
class AnalyzePlaylistUseCase
    implements BaseUseCase<Result<List<VideoInfo>>, String> {
  final VideoRepository _videoRepository;

  const AnalyzePlaylistUseCase({required VideoRepository videoRepository})
    : _videoRepository = videoRepository;

  @override
  Future<Result<List<VideoInfo>>> execute(String playlistUrl) async {
    try {
      // Validate URL first
      if (!_videoRepository.isValidPlaylistUrl(playlistUrl)) {
        return Result.failure('Invalid YouTube playlist URL format');
      }

      // Extract playlist ID for additional validation
      final playlistId = _videoRepository.extractPlaylistId(playlistUrl);
      if (playlistId == null) {
        return Result.failure('Could not extract playlist ID from URL');
      }

      // Analyze playlist using repository
      final videos = await _videoRepository.analyzePlaylist(playlistUrl);

      return Result.success(videos);
    } catch (e) {
      return Result.failure('Failed to analyze playlist: $e');
    }
  }
}
