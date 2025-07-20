import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/video_info.dart';
import '../../domain/repositories/video_repository.dart';
import '../../core/error/failures.dart';
import '../datasources/youtube_datasource.dart';

@Injectable(as: VideoRepository)
class VideoRepositoryImpl implements VideoRepository {
  final YouTubeDataSource dataSource;

  VideoRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, VideoInfo>> analyzeVideo(String url) async {
    try {
      final videoInfo = await dataSource.getVideoInfo(url);
      return Right(videoInfo);
    } catch (e) {
      return Left(ServerFailure('Failed to analyze video: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> validateUrl(String url) async {
    try {
      final isValid = await dataSource.validateUrl(url);
      return Right(isValid);
    } catch (e) {
      return Left(ServerFailure('Failed to validate URL: $e'));
    }
  }
}
