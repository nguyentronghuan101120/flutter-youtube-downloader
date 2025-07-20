# 🚀 Next Steps - Sprint 1.2 Video Analysis & Metadata (Week 2)

## 📋 Tổng quan

Tài liệu này cung cấp các bước hành động cụ thể để hoàn thành Sprint 1.2 - Video Analysis & Metadata. Dựa trên Sprint Checklist, tất cả 10 tasks đều chưa được thực hiện và cần được triển khai theo thứ tự ưu tiên để xây dựng trên foundation của Sprint 1.1.

---

## ⚡ Immediate Actions

### Task 1: Implement Video Repository Implementation

- **Thời gian ước tính:** 45 phút
- **Mô tả:** Triển khai concrete video repository với YouTube API integration và caching mechanism
- **File:** `lib/data/repositories/video_repository_impl.dart`
- **Trạng thái:** [ ] TO DO

```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/video_info.dart';
import '../../domain/repositories/video_repository.dart';
import '../../core/error/failures.dart';
import '../datasources/youtube_datasource.dart';
import '../models/video_info_model.dart';

@Injectable(as: VideoRepository)
class VideoRepositoryImpl implements VideoRepository {
  final YouTubeDataSource _dataSource;
  final Map<String, VideoInfo> _cache = {};

  VideoRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, VideoInfo>> analyzeVideo(String url) async {
    try {
      // Check cache first
      if (_cache.containsKey(url)) {
        return Right(_cache[url]!);
      }

      // Get video info from data source
      final videoInfoModel = await _dataSource.getVideoInfo(url);
      final videoInfo = videoInfoModel.toDomain();

      // Cache the result
      _cache[url] = videoInfo;

      return Right(videoInfo);
    } catch (e) {
      if (e.toString().contains('Video unavailable')) {
        return Left(VideoUnavailableFailure('Video is not available'));
      } else if (e.toString().contains('Network')) {
        return Left(NetworkFailure('Network error occurred'));
      } else {
        return Left(ServerFailure('Failed to analyze video: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> validateUrl(String url) async {
    try {
      final isValid = await _dataSource.validateUrl(url);
      return Right(isValid);
    } catch (e) {
      return Left(ValidationFailure('URL validation failed: $e'));
    }
  }

  void clearCache() {
    _cache.clear();
  }

  void removeFromCache(String url) {
    _cache.remove(url);
  }
}
```

### Task 2: Implement Playlist Info Data Model

- **Thời gian ước tính:** 35 phút
- **Mô tả:** Tạo playlist data model với video list và pagination support
- **File:** `lib/data/models/playlist_info_model.dart`
- **Trạng thái:** [ ] TO DO

```dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/playlist_info.dart' as domain;
import 'video_info_model.dart';

part 'playlist_info_model.g.dart';

@JsonSerializable()
class PlaylistInfoModel {
  final String id;
  final String title;
  final String description;
  final String author;
  final int videoCount;
  final List<VideoInfoModel> videos;
  final String? thumbnailUrl;
  final DateTime? createdAt;
  final bool hasNextPage;
  final String? nextPageToken;

  PlaylistInfoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.videoCount,
    required this.videos,
    this.thumbnailUrl,
    this.createdAt,
    this.hasNextPage = false,
    this.nextPageToken,
  });

  factory PlaylistInfoModel.fromJson(Map<String, dynamic> json) =>
      _$PlaylistInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlaylistInfoModelToJson(this);

  domain.PlaylistInfo toDomain() {
    return domain.PlaylistInfo(
      id: id,
      title: title,
      description: description,
      author: author,
      videoCount: videoCount,
      videos: videos.map((v) => v.toDomain()).toList(),
      thumbnailUrl: thumbnailUrl,
      createdAt: createdAt,
      hasNextPage: hasNextPage,
      nextPageToken: nextPageToken,
    );
  }

  PlaylistInfoModel copyWith({
    String? id,
    String? title,
    String? description,
    String? author,
    int? videoCount,
    List<VideoInfoModel>? videos,
    String? thumbnailUrl,
    DateTime? createdAt,
    bool? hasNextPage,
    String? nextPageToken,
  }) {
    return PlaylistInfoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      author: author ?? this.author,
      videoCount: videoCount ?? this.videoCount,
      videos: videos ?? this.videos,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      nextPageToken: nextPageToken ?? this.nextPageToken,
    );
  }
}
```

### Task 3: Implement Playlist Info Entity

- **Thời gian ước tính:** 25 phút
- **Mô tả:** Tạo playlist entity với video collection và metadata fields
- **File:** `lib/domain/entities/playlist_info.dart`
- **Trạng thái:** [ ] TO DO

```dart
import 'package:equatable/equatable.dart';
import 'video_info.dart';

class PlaylistInfo extends Equatable {
  final String id;
  final String title;
  final String description;
  final String author;
  final int videoCount;
  final List<VideoInfo> videos;
  final String? thumbnailUrl;
  final DateTime? createdAt;
  final bool hasNextPage;
  final String? nextPageToken;

  const PlaylistInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.videoCount,
    required this.videos,
    this.thumbnailUrl,
    this.createdAt,
    this.hasNextPage = false,
    this.nextPageToken,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        author,
        videoCount,
        videos,
        thumbnailUrl,
        createdAt,
        hasNextPage,
        nextPageToken,
      ];

  PlaylistInfo copyWith({
    String? id,
    String? title,
    String? description,
    String? author,
    int? videoCount,
    List<VideoInfo>? videos,
    String? thumbnailUrl,
    DateTime? createdAt,
    bool? hasNextPage,
    String? nextPageToken,
  }) {
    return PlaylistInfo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      author: author ?? this.author,
      videoCount: videoCount ?? this.videoCount,
      videos: videos ?? this.videos,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      nextPageToken: nextPageToken ?? this.nextPageToken,
    );
  }
}
```

### Task 4: Implement Analyze Playlist Use Case

- **Thời gian ước tính:** 40 phút
- **Mô tả:** Triển khai playlist analysis use case với batch processing
- **File:** `lib/domain/usecases/analyze_playlist.dart`
- **Trạng thái:** [ ] TO DO

```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/playlist_info.dart';
import '../entities/video_info.dart';
import '../repositories/video_repository.dart';
import '../../core/error/failures.dart';

@injectable
class AnalyzePlaylistUseCase {
  final VideoRepository _videoRepository;

  AnalyzePlaylistUseCase(this._videoRepository);

  Future<Either<Failure, PlaylistInfo>> call(String playlistUrl) async {
    try {
      // Validate playlist URL
      if (!_isValidPlaylistUrl(playlistUrl)) {
        return Left(InvalidUrlFailure('Invalid playlist URL format'));
      }

      // Get playlist info from repository
      final playlistResult = await _videoRepository.getPlaylistInfo(playlistUrl);

      return playlistResult.fold(
        (failure) => Left(failure),
        (playlistInfo) async {
          // Analyze videos in batch (limit to 10 videos per batch)
          final analyzedVideos = <VideoInfo>[];
          final batchSize = 10;

          for (int i = 0; i < playlistInfo.videos.length; i += batchSize) {
            final end = (i + batchSize < playlistInfo.videos.length)
                ? i + batchSize
                : playlistInfo.videos.length;
            final batch = playlistInfo.videos.sublist(i, end);

            // Analyze each video in the batch
            for (final video in batch) {
              final result = await _videoRepository.analyzeVideo(video.url);
              result.fold(
                (failure) => null, // Skip failed videos
                (videoInfo) => analyzedVideos.add(videoInfo),
              );
            }

            // Add delay between batches to respect rate limits
            if (end < playlistInfo.videos.length) {
              await Future.delayed(const Duration(milliseconds: 500));
            }
          }

          return Right(playlistInfo.copyWith(videos: analyzedVideos));
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to analyze playlist: $e'));
    }
  }

  bool _isValidPlaylistUrl(String url) {
    final playlistRegex = RegExp(
      r'^(https?://)?(www\.)?youtube\.com/playlist\?list=[\w-]+$',
      caseSensitive: false,
    );
    return playlistRegex.hasMatch(url);
  }
}
```

### Task 5: Create Video Info Display Widget

- **Thời gian ước tính:** 50 phút
- **Mô tả:** Tạo video info display widget với metadata và thumbnail
- **File:** `lib/presentation/widgets/video_info_widget.dart`
- **Trạng thái:** [ ] TO DO

```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/video_info.dart';

class VideoInfoWidget extends StatelessWidget {
  final VideoInfo videoInfo;
  final VoidCallback? onDownloadPressed;
  final bool isLoading;

  const VideoInfoWidget({
    Key? key,
    required this.videoInfo,
    this.onDownloadPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: videoInfo.thumbnailUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  videoInfo.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Duration
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(videoInfo.duration),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Description
                if (videoInfo.description.isNotEmpty) ...[
                  Text(
                    'Mô tả:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    videoInfo.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                ],

                // Available Formats
                Text(
                  'Định dạng có sẵn:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: videoInfo.formats.take(5).map((format) {
                    return Chip(
                      label: Text('${format.quality} (${format.extension})'),
                      backgroundColor: Colors.blue[50],
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Download Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : onDownloadPressed,
                    icon: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                    label: Text(isLoading ? 'Đang xử lý...' : 'Tải xuống'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
```

### Task 6: Create Video Analysis Page

- **Thời gian ước tính:** 45 phút
- **Mô tả:** Tạo video analysis page với loading states và error handling
- **File:** `lib/presentation/pages/video_analysis_page.dart`
- **Trạng thái:** [ ] TO DO

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/video_analysis/video_analysis_cubit.dart';
import '../widgets/url_input_widget.dart';
import '../widgets/video_info_widget.dart';

class VideoAnalysisPage extends StatelessWidget {
  const VideoAnalysisPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân tích Video YouTube'),
        elevation: 2,
      ),
      body: BlocProvider(
        create: (context) => context.read<VideoAnalysisCubit>(),
        child: const _VideoAnalysisView(),
      ),
    );
  }
}

class _VideoAnalysisView extends StatelessWidget {
  const _VideoAnalysisView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VideoAnalysisCubit, VideoAnalysisState>(
      listener: (context, state) {
        if (state is VideoAnalysisError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Thử lại',
                textColor: Colors.white,
                onPressed: () {
                  // Retry logic can be implemented here
                },
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // URL Input Section
              UrlInputWidget(
                onUrlSubmitted: (url) {
                  context.read<VideoAnalysisCubit>().analyzeVideo(url);
                },
              ),

              const SizedBox(height: 24),

              // Content Section
              Expanded(
                child: _buildContent(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, VideoAnalysisState state) {
    if (state is VideoAnalysisInitial) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nhập URL YouTube để bắt đầu phân tích',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (state is VideoAnalysisLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang phân tích video...'),
          ],
        ),
      );
    }

    if (state is VideoAnalysisSuccess) {
      return SingleChildScrollView(
        child: VideoInfoWidget(
          videoInfo: state.videoInfo,
          onDownloadPressed: () {
            // Navigate to download page or show format selection
            _showFormatSelectionDialog(context, state.videoInfo);
          },
        ),
      );
    }

    if (state is VideoAnalysisError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Lỗi: ${state.message}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<VideoAnalysisCubit>().reset();
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showFormatSelectionDialog(BuildContext context, VideoInfo videoInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn định dạng'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: videoInfo.formats.length,
            itemBuilder: (context, index) {
              final format = videoInfo.formats[index];
              return ListTile(
                title: Text('${format.quality} (${format.extension})'),
                subtitle: format.bitrate != null
                    ? Text('${(format.bitrate! / 1000).round()} kbps')
                    : null,
                onTap: () {
                  Navigator.of(context).pop(format);
                  // Handle format selection
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }
}
```

### Task 7: Implement Error Handling System

- **Thời gian ước tính:** 30 phút
- **Mô tả:** Triển khai comprehensive error handling và failure types
- **File:** `lib/core/error/failures.dart`
- **Trạng thái:** [ ] TO DO

```dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

class InvalidUrlFailure extends Failure {
  const InvalidUrlFailure(String message) : super(message);
}

class VideoUnavailableFailure extends Failure {
  const VideoUnavailableFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

class DownloadFailure extends Failure {
  const DownloadFailure(String message) : super(message);
}

class StorageFailure extends Failure {
  const StorageFailure(String message) : super(message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(String message) : super(message);
}

class PlaylistFailure extends Failure {
  const PlaylistFailure(String message) : super(message);
}
```

### Task 8: Create YouTube Service Wrapper

- **Thời gian ước tính:** 40 phút
- **Mô tả:** Tạo YouTube service wrapper với retry mechanism và rate limiting
- **File:** `lib/core/services/youtube_service.dart`
- **Trạng thái:** [ ] TO DO

```dart
import 'package:injectable/injectable.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../error/failures.dart';

@injectable
class YouTubeService {
  final YoutubeExplode _yt;
  final Map<String, DateTime> _lastRequestTime = {};
  final Duration _rateLimitDelay = const Duration(milliseconds: 100);

  YouTubeService() : _yt = YoutubeExplode();

  Future<T> _withRetry<T>(Future<T> Function() operation, {int maxRetries = 3}) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          throw e;
        }

        // Exponential backoff
        await Future.delayed(Duration(milliseconds: 1000 * attempts));
      }
    }
    throw Exception('Max retries exceeded');
  }

  Future<void> _enforceRateLimit(String endpoint) async {
    final now = DateTime.now();
    final lastRequest = _lastRequestTime[endpoint];

    if (lastRequest != null) {
      final timeSinceLastRequest = now.difference(lastRequest);
      if (timeSinceLastRequest < _rateLimitDelay) {
        await Future.delayed(_rateLimitDelay - timeSinceLastRequest);
      }
    }

    _lastRequestTime[endpoint] = now;
  }

  Future<Video> getVideo(String url) async {
    await _enforceRateLimit('video');

    return _withRetry(() async {
      return await _yt.videos.get(url);
    });
  }

  Future<StreamManifest> getStreamManifest(String url) async {
    await _enforceRateLimit('manifest');

    return _withRetry(() async {
      return await _yt.videos.streamsClient.getManifest(url);
    });
  }

  Future<Playlist> getPlaylist(String url) async {
    await _enforceRateLimit('playlist');

    return _withRetry(() async {
      return await _yt.playlists.get(url);
    });
  }

  Future<List<Video>> getPlaylistVideos(String url, {int? limit}) async {
    await _enforceRateLimit('playlist_videos');

    return _withRetry(() async {
      final videos = <Video>[];
      final playlist = _yt.playlists.getVideos(url);

      await for (final video in playlist) {
        videos.add(video);
        if (limit != null && videos.length >= limit) break;
      }

      return videos;
    });
  }

  Future<bool> validateUrl(String url) async {
    try {
      await _enforceRateLimit('validate');

      return _withRetry(() async {
        await _yt.videos.get(url);
        return true;
      });
    } catch (e) {
      return false;
    }
  }

  Future<bool> isPlaylistUrl(String url) async {
    return url.contains('playlist?list=');
  }

  void dispose() {
    _yt.close();
  }
}
```

### Task 9: Enhance Video Analysis State Management

- **Thời gian ước tính:** 35 phút
- **Mô tả:** Mở rộng state management với comprehensive states
- **File:** `lib/presentation/bloc/video_analysis/video_analysis_state.dart`
- **Trạng thái:** [ ] TO DO

```dart
part of 'video_analysis_cubit.dart';

abstract class VideoAnalysisState extends Equatable {
  const VideoAnalysisState();

  @override
  List<Object?> get props => [];
}

class VideoAnalysisInitial extends VideoAnalysisState {}

class VideoAnalysisLoading extends VideoAnalysisState {
  final String? message;

  const VideoAnalysisLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class VideoAnalysisSuccess extends VideoAnalysisState {
  final VideoInfo videoInfo;
  final DateTime analyzedAt;

  const VideoAnalysisSuccess(this.videoInfo) : analyzedAt = DateTime.now();

  @override
  List<Object?> get props => [videoInfo, analyzedAt];
}

class VideoAnalysisError extends VideoAnalysisState {
  final String message;
  final String? url;
  final DateTime errorAt;

  const VideoAnalysisError(this.message, {this.url}) : errorAt = DateTime.now();

  @override
  List<Object?> get props => [message, url, errorAt];
}

class VideoAnalysisRetrying extends VideoAnalysisState {
  final String url;
  final int retryCount;
  final String? lastError;

  const VideoAnalysisRetrying({
    required this.url,
    required this.retryCount,
    this.lastError,
  });

  @override
  List<Object?> get props => [url, retryCount, lastError];
}

class PlaylistAnalysisLoading extends VideoAnalysisState {
  final int totalVideos;
  final int analyzedVideos;
  final String currentVideoTitle;

  const PlaylistAnalysisLoading({
    required this.totalVideos,
    required this.analyzedVideos,
    required this.currentVideoTitle,
  });

  @override
  List<Object?> get props => [totalVideos, analyzedVideos, currentVideoTitle];
}
```

### Task 10: Write Unit Tests for Video Analysis

- **Thời gian ước tính:** 50 phút
- **Mô tả:** Viết comprehensive unit tests cho video analysis functionality
- **File:** `test/domain/usecases/analyze_video_test.dart`
- **Trạng thái:** [ ] TO DO

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_youtube_downloader/domain/entities/video_info.dart';
import 'package:flutter_youtube_downloader/domain/repositories/video_repository.dart';
import 'package:flutter_youtube_downloader/domain/usecases/analyze_video.dart';
import 'package:flutter_youtube_downloader/core/error/failures.dart';

import 'analyze_video_test.mocks.dart';

@GenerateMocks([VideoRepository])
void main() {
  late AnalyzeVideoUseCase useCase;
  late MockVideoRepository mockRepository;

  setUp(() {
    mockRepository = MockVideoRepository();
    useCase = AnalyzeVideoUseCase(mockRepository);
  });

  const testUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
  const testVideoInfo = VideoInfo(
    id: 'dQw4w9WgXcQ',
    title: 'Test Video',
    description: 'Test Description',
    duration: Duration(minutes: 3, seconds: 33),
    thumbnailUrl: 'https://example.com/thumbnail.jpg',
    formats: [],
    url: testUrl,
  );

  group('AnalyzeVideoUseCase', () {
    test('should return VideoInfo when URL is valid and repository succeeds', () async {
      // arrange
      when(mockRepository.validateUrl(testUrl))
          .thenAnswer((_) async => const Right(true));
      when(mockRepository.analyzeVideo(testUrl))
          .thenAnswer((_) async => const Right(testVideoInfo));

      // act
      final result = await useCase(testUrl);

      // assert
      expect(result, const Right(testVideoInfo));
      verify(mockRepository.validateUrl(testUrl));
      verify(mockRepository.analyzeVideo(testUrl));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return InvalidUrlFailure when URL format is invalid', () async {
      // arrange
      const invalidUrl = 'invalid-url';

      // act
      final result = await useCase(invalidUrl);

      // assert
      expect(result, isA<Left<InvalidUrlFailure>>());
      verifyNever(mockRepository.validateUrl(invalidUrl));
      verifyNever(mockRepository.analyzeVideo(invalidUrl));
    });

    test('should return InvalidUrlFailure when repository validation fails', () async {
      // arrange
      when(mockRepository.validateUrl(testUrl))
          .thenAnswer((_) async => const Right(false));

      // act
      final result = await useCase(testUrl);

      // assert
      expect(result, isA<Left<InvalidUrlFailure>>());
      verify(mockRepository.validateUrl(testUrl));
      verifyNever(mockRepository.analyzeVideo(testUrl));
    });

    test('should return failure when repository validation returns failure', () async {
      // arrange
      const failure = NetworkFailure('Network error');
      when(mockRepository.validateUrl(testUrl))
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await useCase(testUrl);

      // assert
      expect(result, const Left(failure));
      verify(mockRepository.validateUrl(testUrl));
      verifyNever(mockRepository.analyzeVideo(testUrl));
    });

    test('should return failure when repository analyzeVideo returns failure', () async {
      // arrange
      const failure = ServerFailure('Server error');
      when(mockRepository.validateUrl(testUrl))
          .thenAnswer((_) async => const Right(true));
      when(mockRepository.analyzeVideo(testUrl))
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await useCase(testUrl);

      // assert
      expect(result, const Left(failure));
      verify(mockRepository.validateUrl(testUrl));
      verify(mockRepository.analyzeVideo(testUrl));
    });

    test('should handle different YouTube URL formats', () async {
      final testUrls = [
        'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'https://youtu.be/dQw4w9WgXcQ',
        'http://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'youtube.com/watch?v=dQw4w9WgXcQ',
      ];

      for (final url in testUrls) {
        when(mockRepository.validateUrl(url))
            .thenAnswer((_) async => const Right(true));
        when(mockRepository.analyzeVideo(url))
            .thenAnswer((_) async => const Right(testVideoInfo));

        final result = await useCase(url);

        expect(result, const Right(testVideoInfo));
        verify(mockRepository.validateUrl(url));
        verify(mockRepository.analyzeVideo(url));
      }
    });
  });
}
```

---

## 🎯 Expected Results

Sau khi hoàn thành tất cả 10 tasks, kết quả mong đợi:

1. **Data Layer Implementation:** Video repository với caching và playlist support
2. **Domain Layer Enhancement:** Playlist analysis và comprehensive error handling
3. **Presentation Layer:** Video analysis page với loading states và error handling
4. **Testing Foundation:** Unit tests cho video analysis functionality

**Deliverables đạt được:**

- ✅ Video analysis functionality hoàn chỉnh
- ✅ Playlist support với batch processing
- ✅ Comprehensive error handling system
- ✅ Video info display với metadata
- ✅ YouTube service wrapper với retry mechanism
- ✅ Unit tests cho core functionality

---

## 🔄 Next Steps

Sau khi hoàn thành Sprint 1.2:

1. **Integration Testing:** Kiểm tra video analysis flow end-to-end
2. **Sprint 1.3:** Bắt đầu triển khai format selection và download UI
3. **Performance Optimization:** Cải thiện caching strategy và rate limiting
4. **Error Recovery:** Implement retry mechanism cho failed requests
5. **UI Enhancement:** Cải thiện video info display và user experience

---

## 📝 Notes

### Kiến trúc và Công nghệ:

- **Repository Pattern:** Concrete implementation với caching
- **Error Handling:** Comprehensive failure types và error recovery
- **State Management:** Extended states cho complex scenarios
- **Caching:** Metadata caching cho performance optimization

### Dependencies cần thêm vào pubspec.yaml:

```yaml
dependencies:
  cached_network_image: ^3.3.0
  mockito: ^5.4.4

dev_dependencies:
  build_runner: ^2.4.7
  mockito: ^5.4.4
```

### Performance Considerations:

- **Caching Strategy:** Metadata caching để giảm API calls
- **Rate Limiting:** YouTube API rate limiting compliance
- **Batch Processing:** Playlist analysis với batch processing
- **Error Recovery:** Retry mechanism cho network failures

### Các bước triển khai:

1. Chạy `flutter pub get` để cài đặt dependencies
2. Chạy `flutter packages pub run build_runner build` để generate code
3. Implement các components theo thứ tự ưu tiên
4. Test từng component trước khi chuyển sang task tiếp theo
5. Đảm bảo error handling được implement đầy đủ
6. Viết unit tests cho core functionality
