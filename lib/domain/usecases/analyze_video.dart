import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/video_info.dart';
import '../repositories/video_repository.dart';
import '../../core/error/failures.dart';

@injectable
class AnalyzeVideoUseCase {
  final VideoRepository repository;

  AnalyzeVideoUseCase(this.repository);

  Future<Either<Failure, VideoInfo>> call(String url) async {
    // Validate URL format first
    if (!VideoInfo.isValidUrl(url)) {
      return Left(InvalidInputFailure('Invalid YouTube URL format'));
    }

    // Validate URL with repository
    final validationResult = await repository.validateUrl(url);
    return validationResult.fold((failure) => Left(failure), (isValid) {
      if (!isValid) {
        return Left(InvalidInputFailure('URL validation failed'));
      }
      return repository.analyzeVideo(url);
    });
  }
}
