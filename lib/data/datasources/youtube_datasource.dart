import 'package:injectable/injectable.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/video_info_model.dart';

abstract class YouTubeDataSource {
  Future<VideoInfoModel> getVideoInfo(String url);
  Future<bool> validateUrl(String url);
}

@Injectable(as: YouTubeDataSource)
class YouTubeDataSourceImpl implements YouTubeDataSource {
  final YoutubeExplode _youtubeExplode;

  YouTubeDataSourceImpl(this._youtubeExplode);

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
  Future<bool> validateUrl(String url) async {
    try {
      await _youtubeExplode.videos.get(url);
      return true;
    } catch (e) {
      return false;
    }
  }
}
