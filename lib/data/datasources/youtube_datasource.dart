import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/video_info_model.dart';
import '../models/playlist_info_model.dart';

abstract class YouTubeDataSource {
  Future<VideoInfoModel> getVideoInfo(String url);
  Future<PlaylistInfoModel> getPlaylistInfo(String url);
  Future<List<VideoInfoModel>> getPlaylistVideos(String playlistId);
  Future<bool> isValidYouTubeUrl(String url);
  Future<String> extractVideoId(String url);
  Future<String> extractPlaylistId(String url);
}

class YouTubeDataSourceImpl implements YouTubeDataSource {
  final YoutubeExplode _youtubeExplode;

  YouTubeDataSourceImpl({YoutubeExplode? youtubeExplode})
    : _youtubeExplode = youtubeExplode ?? YoutubeExplode();

  @override
  Future<VideoInfoModel> getVideoInfo(String url) async {
    try {
      final video = await _youtubeExplode.videos.get(url);
      final manifest = await _youtubeExplode.videos.streamsClient.getManifest(
        video.id,
      );

      final videoStreams = manifest.video
          .map(
            (stream) => VideoStreamModel(
              url: stream.url.toString(),
              format: stream.container.name,
              quality: stream.videoQuality.name,
              width: 1920, // Default width
              height: 1080, // Default height
              bitrate: 1000000, // Default bitrate
              fileSize: stream.size.totalBytes,
              codec: 'H.264', // Default codec
            ),
          )
          .toList();

      final audioStreams = manifest.audioOnly
          .map(
            (stream) => AudioStreamModel(
              url: stream.url.toString(),
              format: stream.container.name,
              bitrate: 128000, // Default bitrate
              fileSize: stream.size.totalBytes,
              codec: 'AAC', // Default codec
            ),
          )
          .toList();

      final subtitles = <SubtitleInfoModel>[];

      return VideoInfoModel(
        id: video.id.value,
        title: video.title,
        description: video.description,
        duration: video.duration ?? Duration.zero,
        channelName: video.author,
        channelId: video.channelId.value,
        thumbnailUrl: video.thumbnails.highResUrl,
        uploadDate: video.uploadDate?.toIso8601String(),
        viewCount: video.engagement.viewCount,
        likeCount: video.engagement.likeCount,
        videoStreams: videoStreams,
        audioStreams: audioStreams,
        subtitles: subtitles,
        isPrivate: false, // Default value
        isAgeRestricted: false, // Default value
        isRegionBlocked: false,
      );
    } catch (e) {
      throw Exception('Failed to get video info: $e');
    }
  }

  @override
  Future<PlaylistInfoModel> getPlaylistInfo(String url) async {
    try {
      final playlist = await _youtubeExplode.playlists.get(url);
      final videos = await _youtubeExplode.playlists
          .getVideos(playlist.id)
          .toList();

      final videoModels = await Future.wait(
        videos.map((video) => getVideoInfo(video.url)),
      );

      return PlaylistInfoModel(
        id: playlist.id.value,
        title: playlist.title,
        description: playlist.description,
        channelName: playlist.author,
        channelId: '', // Default empty string
        thumbnailUrl: playlist.thumbnails.highResUrl,
        videoCount: videos.length,
        videos: videoModels,
        isPrivate: false, // Default value
        isRegionBlocked: false,
      );
    } catch (e) {
      throw Exception('Failed to get playlist info: $e');
    }
  }

  @override
  Future<List<VideoInfoModel>> getPlaylistVideos(String playlistId) async {
    try {
      final videos = await _youtubeExplode.playlists
          .getVideos(playlistId)
          .toList();
      return await Future.wait(videos.map((video) => getVideoInfo(video.url)));
    } catch (e) {
      throw Exception('Failed to get playlist videos: $e');
    }
  }

  @override
  Future<bool> isValidYouTubeUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      return uri.host.contains('youtube.com') || uri.host.contains('youtu.be');
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String> extractVideoId(String url) async {
    try {
      final video = await _youtubeExplode.videos.get(url);
      return video.id.value;
    } catch (e) {
      throw Exception('Failed to extract video ID: $e');
    }
  }

  @override
  Future<String> extractPlaylistId(String url) async {
    try {
      final playlist = await _youtubeExplode.playlists.get(url);
      return playlist.id.value;
    } catch (e) {
      throw Exception('Failed to extract playlist ID: $e');
    }
  }
}
