import 'package:dartz/dartz.dart';
import '../entities/video_info.dart';
import '../entities/playlist_info.dart';
import '../../core/error/failures.dart';

abstract class VideoRepository {
  /// Analyzes a YouTube video URL and returns video information
  ///
  /// Returns [VideoInfo] on success, [Failure] on error
  Future<Either<Failure, VideoInfo>> analyzeVideo(String url);

  /// Validates if the provided URL is a valid YouTube URL
  Future<Either<Failure, bool>> validateUrl(String url);

  /// Gets playlist information from a YouTube playlist URL
  ///
  /// Returns [PlaylistInfo] on success, [Failure] on error
  Future<Either<Failure, PlaylistInfo>> getPlaylistInfo(String url);

  /// Clears the video metadata cache
  Future<Either<Failure, void>> clearCache();

  /// Gets cached video information if available
  Future<Either<Failure, VideoInfo?>> getCachedVideo(String url);
}
