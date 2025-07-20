import 'package:dartz/dartz.dart';
import '../entities/video_info.dart';
import '../../core/error/failures.dart';

abstract class VideoRepository {
  /// Analyzes a YouTube video URL and returns video information
  ///
  /// Returns [VideoInfo] on success, [Failure] on error
  Future<Either<Failure, VideoInfo>> analyzeVideo(String url);

  /// Validates if the provided URL is a valid YouTube URL
  Future<Either<Failure, bool>> validateUrl(String url);
}
