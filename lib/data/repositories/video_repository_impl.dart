import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/video_info.dart';
import '../../domain/entities/playlist_info.dart';
import '../../domain/repositories/video_repository.dart';
import '../../core/error/failures.dart';
import '../datasources/youtube_datasource.dart';
import '../models/video_info_model.dart';
import '../models/playlist_info_model.dart';

@Injectable(as: VideoRepository)
class VideoRepositoryImpl implements VideoRepository {
  final YouTubeDataSource dataSource;

  // Simple in-memory cache for video metadata
  final Map<String, VideoInfoModel> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 30);

  VideoRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, VideoInfo>> analyzeVideo(String url) async {
    try {
      // Check cache first
      if (_isCacheValid(url)) {
        return Right(_cache[url]!);
      }

      // Fetch from data source
      final videoInfo = await dataSource.getVideoInfo(url);

      // Cache the result
      _cache[url] = videoInfo;
      _cacheTimestamps[url] = DateTime.now();

      return Right(videoInfo);
    } on FormatException catch (e) {
      return Left(InvalidInputFailure('Invalid video URL format: $e'));
    } catch (e) {
      if (e.toString().contains('Video unavailable')) {
        return Left(VideoUnavailableFailure('Video is unavailable or private'));
      } else if (e.toString().contains('Network')) {
        return Left(NetworkFailure('Network error: $e'));
      } else {
        return Left(ServerFailure('Failed to analyze video: $e'));
      }
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

  @override
  Future<Either<Failure, PlaylistInfo>> getPlaylistInfo(String url) async {
    try {
      final playlistInfo = await dataSource.getPlaylistInfo(url);
      return Right(playlistInfo);
    } on FormatException catch (e) {
      return Left(InvalidInputFailure('Invalid playlist URL format: $e'));
    } catch (e) {
      if (e.toString().contains('Playlist unavailable')) {
        return Left(
          PlaylistNotFoundFailure('Playlist is unavailable or private'),
        );
      } else if (e.toString().contains('Network')) {
        return Left(NetworkFailure('Network error: $e'));
      } else {
        return Left(ServerFailure('Failed to get playlist info: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      _cache.clear();
      _cacheTimestamps.clear();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear cache: $e'));
    }
  }

  @override
  Future<Either<Failure, VideoInfo?>> getCachedVideo(String url) async {
    try {
      if (_isCacheValid(url)) {
        return Right(_cache[url]!);
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to get cached video: $e'));
    }
  }

  bool _isCacheValid(String url) {
    final timestamp = _cacheTimestamps[url];
    if (timestamp == null) return false;

    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }
}
