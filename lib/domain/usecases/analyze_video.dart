import '../entities/video_info.dart';
import '../repositories/video_repository.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

class AnalyzeVideo {
  final VideoRepository repository;

  AnalyzeVideo({required this.repository});

  Future<Either<Failure, VideoInfo>> call(String url) async {
    try {
      // Validate URL trước
      final isValid = await repository.isValidYouTubeUrl(url);
      if (!isValid) {
        return const Left(InvalidInputFailure('Invalid YouTube URL'));
      }

      // Phân tích video
      final videoInfo = await repository.getVideoInfo(url);
      return Right(videoInfo);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
