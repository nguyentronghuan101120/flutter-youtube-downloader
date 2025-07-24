import 'package:injectable/injectable.dart';
import '../../domain/entities/video_info.dart';
import '../../domain/repositories/video_repository.dart';
import '../datasources/youtube_datasource.dart';
import '../../core/services/youtube_service.dart';

@LazySingleton(as: VideoRepository)
class VideoRepositoryImpl implements VideoRepository {
  final YouTubeDataSource _dataSource;
  final YouTubeService _youtubeService;

  VideoRepositoryImpl({
    required YouTubeDataSource dataSource,
    required YouTubeService youtubeService,
  }) : _dataSource = dataSource,
       _youtubeService = youtubeService;

  @override
  Future<VideoInfo> analyzeVideo(String url) async {
    try {
      // Use YouTube service for enhanced functionality with retry mechanism
      return await _youtubeService.analyzeVideo(url);
    } catch (e) {
      throw Exception('Failed to analyze video: $e');
    }
  }

  @override
  Future<List<VideoInfo>> analyzePlaylist(String playlistUrl) async {
    try {
      // Use YouTube service for enhanced playlist analysis with batch processing
      final playlistInfo = await _youtubeService.analyzePlaylist(playlistUrl);
      return playlistInfo.videos;
    } catch (e) {
      throw Exception('Failed to analyze playlist: $e');
    }
  }

  @override
  bool isValidVideoUrl(String url) {
    return _dataSource.isValidVideoUrl(url);
  }

  @override
  bool isValidPlaylistUrl(String url) {
    return _dataSource.isValidPlaylistUrl(url);
  }

  @override
  String? extractVideoId(String url) {
    return _dataSource.extractVideoId(url);
  }

  @override
  String? extractPlaylistId(String url) {
    return _dataSource.extractPlaylistId(url);
  }
}
