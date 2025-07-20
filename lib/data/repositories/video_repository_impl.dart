import 'package:injectable/injectable.dart';
import '../../domain/entities/video_info.dart';
import '../../domain/entities/playlist_info.dart';
import '../../domain/repositories/video_repository.dart';
import '../datasources/youtube_datasource.dart';

@Injectable(as: VideoRepository)
class VideoRepositoryImpl implements VideoRepository {
  final YouTubeDataSource dataSource;

  VideoRepositoryImpl(this.dataSource);

  @override
  Future<VideoInfo> getVideoInfo(String url) async {
    try {
      return await dataSource.getVideoInfo(url);
    } catch (e) {
      throw Exception('Failed to get video info: $e');
    }
  }

  @override
  Future<PlaylistInfo> getPlaylistInfo(String url) async {
    try {
      return await dataSource.getPlaylistInfo(url);
    } catch (e) {
      throw Exception('Failed to get playlist info: $e');
    }
  }

  @override
  Future<List<VideoInfo>> getPlaylistVideos(String playlistId) async {
    try {
      return await dataSource.getPlaylistVideos(playlistId);
    } catch (e) {
      throw Exception('Failed to get playlist videos: $e');
    }
  }

  @override
  Future<bool> isValidYouTubeUrl(String url) async {
    try {
      return await dataSource.isValidYouTubeUrl(url);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String> extractVideoId(String url) async {
    try {
      return await dataSource.extractVideoId(url);
    } catch (e) {
      throw Exception('Failed to extract video ID: $e');
    }
  }

  @override
  Future<String> extractPlaylistId(String url) async {
    try {
      return await dataSource.extractPlaylistId(url);
    } catch (e) {
      throw Exception('Failed to extract playlist ID: $e');
    }
  }
}
