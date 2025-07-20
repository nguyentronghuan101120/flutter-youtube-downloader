import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/playlist_info.dart';
import '../entities/video_info.dart';
import '../repositories/video_repository.dart';
import '../../core/error/failures.dart';

@injectable
class AnalyzePlaylist {
  final VideoRepository repository;

  AnalyzePlaylist(this.repository);

  /// Analyzes a YouTube playlist URL and returns playlist information
  ///
  /// [url] - The YouTube playlist URL to analyze
  /// [maxVideos] - Maximum number of videos to analyze (for performance)
  /// [includeVideoDetails] - Whether to fetch detailed info for each video
  Future<Either<Failure, PlaylistInfo>> call({
    required String url,
    int maxVideos = 50,
    bool includeVideoDetails = true,
  }) async {
    try {
      // Validate URL format
      if (!_isValidPlaylistUrl(url)) {
        return Left(InvalidInputFailure('Invalid playlist URL format'));
      }

      // Get playlist basic info
      final playlistResult = await repository.getPlaylistInfo(url);

      return playlistResult.fold((failure) => Left(failure), (
        playlistInfo,
      ) async {
        // If we don't need video details, return basic info
        if (!includeVideoDetails) {
          return Right(playlistInfo);
        }

        // Process videos in batches for better performance
        final processedVideos = await _processVideosInBatches(
          playlistInfo.videos,
          maxVideos,
        );

        // Create updated playlist info with processed videos
        final updatedPlaylist = playlistInfo.copyWith(videos: processedVideos);

        return Right(updatedPlaylist);
      });
    } catch (e) {
      return Left(ServerFailure('Failed to analyze playlist: $e'));
    }
  }

  /// Process videos in batches to avoid overwhelming the API
  Future<List<VideoInfo>> _processVideosInBatches(
    List<VideoInfo> videos,
    int maxVideos,
  ) async {
    final videosToProcess = videos.take(maxVideos).toList();
    final processedVideos = <VideoInfo>[];

    const batchSize = 10;

    for (int i = 0; i < videosToProcess.length; i += batchSize) {
      final batch = videosToProcess.skip(i).take(batchSize).toList();

      // Process batch concurrently
      final batchResults = await Future.wait(
        batch.map((video) => _processVideo(video)),
      );

      processedVideos.addAll(batchResults.whereType<VideoInfo>());

      // Add small delay between batches to respect rate limits
      if (i + batchSize < videosToProcess.length) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    return processedVideos;
  }

  /// Process individual video to get detailed information
  Future<VideoInfo?> _processVideo(VideoInfo video) async {
    try {
      // If video already has complete info, return as is
      if (video.videoStreams.isNotEmpty || video.audioStreams.isNotEmpty) {
        return video;
      }

      // Get detailed video info
      final result = await repository.analyzeVideo(video.id);
      return result.fold(
        (failure) => null, // Skip failed videos
        (detailedVideo) => detailedVideo,
      );
    } catch (e) {
      return null; // Skip failed videos
    }
  }

  /// Validates if the URL is a valid YouTube playlist URL
  bool _isValidPlaylistUrl(String url) {
    return url.contains('youtube.com/playlist') ||
        url.contains('youtube.com/watch') && url.contains('list=');
  }
}
