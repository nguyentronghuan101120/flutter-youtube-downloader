import 'package:injectable/injectable.dart';
import '../entities/video_info.dart';
import '../repositories/video_repository.dart';
import '../../core/usecases/base_usecase.dart';
import '../../core/result/result.dart';

@injectable
class AnalyzeVideoUseCase implements BaseUseCase<Result<VideoInfo>, String> {
  final VideoRepository _videoRepository;

  const AnalyzeVideoUseCase({required VideoRepository videoRepository})
    : _videoRepository = videoRepository;

  @override
  Future<Result<VideoInfo>> execute(String url) async {
    try {
      // Validate URL format
      if (!_videoRepository.isValidVideoUrl(url)) {
        return Result.failure('Invalid YouTube video URL format');
      }

      // Extract video ID for additional validation
      final videoId = _videoRepository.extractVideoId(url);
      if (videoId == null) {
        return Result.failure('Could not extract video ID from URL');
      }

      // Analyze video using repository
      final videoInfo = await _videoRepository.analyzeVideo(url);

      return Result.success(videoInfo);
    } catch (e) {
      return Result.failure('Failed to analyze video: $e');
    }
  }
}
