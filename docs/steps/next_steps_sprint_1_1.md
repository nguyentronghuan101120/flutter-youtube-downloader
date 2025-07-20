# 🚀 Next Steps - Sprint 1.1 Foundation & URL Input (Week 1)

## 📋 Tổng quan

Tài liệu này cung cấp các bước hành động cụ thể để hoàn thành Sprint 1.1 - Foundation & URL Input. Dựa trên Sprint Checklist, tất cả 10 tasks đều chưa được thực hiện và cần được triển khai theo thứ tự ưu tiên.

---

## ⚡ Immediate Actions

### Task 1: Implement VideoInfo Entity

- **Thời gian ước tính:** 30 phút
- **Mô tả:** Tạo VideoInfo entity trong domain layer với metadata fields và URL validation
- **File:** `lib/domain/entities/video_info.dart`
- **Trạng thái:** [ ] TO DO

```dart
import 'package:equatable/equatable.dart';

class VideoInfo extends Equatable {
  final String id;
  final String title;
  final String description;
  final Duration duration;
  final String thumbnailUrl;
  final List<VideoFormat> formats;
  final String url;

  const VideoInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.thumbnailUrl,
    required this.formats,
    required this.url,
  });

  @override
  List<Object?> get props => [id, title, description, duration, thumbnailUrl, formats, url];

  static bool isValidUrl(String url) {
    final youtubeRegex = RegExp(
      r'^(https?://)?(www\.)?(youtube\.com|youtu\.be)/.+$',
      caseSensitive: false,
    );
    return youtubeRegex.hasMatch(url);
  }
}

class VideoFormat extends Equatable {
  final String formatId;
  final String quality;
  final String extension;
  final int? bitrate;
  final int? width;
  final int? height;

  const VideoFormat({
    required this.formatId,
    required this.quality,
    required this.extension,
    this.bitrate,
    this.width,
    this.height,
  });

  @override
  List<Object?> get props => [formatId, quality, extension, bitrate, width, height];
}
```

### Task 2: Implement DownloadTask Entity

- **Thời gian ước tính:** 25 phút
- **Mô tả:** Tạo DownloadTask entity với status tracking và progress monitoring
- **File:** `lib/domain/entities/download_task.dart`
- **Trạng thái:** [ ] TO DO

```dart
import 'package:equatable/equatable.dart';

enum DownloadStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
  cancelled
}

class DownloadTask extends Equatable {
  final String id;
  final String videoId;
  final String title;
  final String formatId;
  final String outputPath;
  final DownloadStatus status;
  final int bytesDownloaded;
  final int totalBytes;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;

  const DownloadTask({
    required this.id,
    required this.videoId,
    required this.title,
    required this.formatId,
    required this.outputPath,
    this.status = DownloadStatus.pending,
    this.bytesDownloaded = 0,
    this.totalBytes = 0,
    this.errorMessage,
    required this.createdAt,
    this.completedAt,
  });

  double get progress {
    if (totalBytes == 0) return 0.0;
    return bytesDownloaded / totalBytes;
  }

  bool get isCompleted => status == DownloadStatus.completed;
  bool get isFailed => status == DownloadStatus.failed;
  bool get isDownloading => status == DownloadStatus.downloading;

  DownloadTask copyWith({
    String? id,
    String? videoId,
    String? title,
    String? formatId,
    String? outputPath,
    DownloadStatus? status,
    int? bytesDownloaded,
    int? totalBytes,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return DownloadTask(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      formatId: formatId ?? this.formatId,
      outputPath: outputPath ?? this.outputPath,
      status: status ?? this.status,
      bytesDownloaded: bytesDownloaded ?? this.bytesDownloaded,
      totalBytes: totalBytes ?? this.totalBytes,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        videoId,
        title,
        formatId,
        outputPath,
        status,
        bytesDownloaded,
        totalBytes,
        errorMessage,
        createdAt,
        completedAt,
      ];
}
```

### Task 3: Define VideoRepository Interface

- **Thời gian ước tính:** 20 phút
- **Mô tả:** Tạo VideoRepository interface với analyzeVideo method và error handling
- **File:** `lib/domain/repositories/video_repository.dart`
- **Trạng thái:** [ ] TO DO

```dart
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
```

### Task 4: Define DownloadRepository Interface

- **Thời gian ước tính:** 25 phút
- **Mô tả:** Tạo DownloadRepository interface với download management methods
- **File:** `lib/domain/repositories/download_repository.dart`
- **Trạng thái:** [ ] TO DO

```dart
import 'package:dartz/dartz.dart';
import '../entities/download_task.dart';
import '../../core/error/failures.dart';

abstract class DownloadRepository {
  /// Starts a new download task
  Future<Either<Failure, DownloadTask>> startDownload(DownloadTask task);

  /// Pauses an active download
  Future<Either<Failure, DownloadTask>> pauseDownload(String taskId);

  /// Resumes a paused download
  Future<Either<Failure, DownloadTask>> resumeDownload(String taskId);

  /// Cancels a download task
  Future<Either<Failure, bool>> cancelDownload(String taskId);

  /// Gets all download tasks
  Future<Either<Failure, List<DownloadTask>>> getDownloads();

  /// Gets a specific download task by ID
  Future<Either<Failure, DownloadTask>> getDownload(String taskId);

  /// Updates download progress
  Future<Either<Failure, DownloadTask>> updateProgress(
    String taskId,
    int bytesDownloaded,
    int totalBytes,
  );
}
```

### Task 5: Implement AnalyzeVideoUseCase

- **Thời gian ước tính:** 30 phút
- **Mô tả:** Triển khai business logic cho video analysis với URL validation
- **File:** `lib/domain/usecases/analyze_video.dart`
- **Trạng thái:** [ ] TO DO

```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/video_info.dart';
import '../repositories/video_repository.dart';
import '../../core/error/failures.dart';

@injectable
class AnalyzeVideoUseCase {
  final VideoRepository repository;

  AnalyzeVideoUseCase(this.repository);

  Future<Either<Failure, VideoInfo>> call(String url) async {
    // Validate URL format first
    if (!VideoInfo.isValidUrl(url)) {
      return Left(InvalidUrlFailure('Invalid YouTube URL format'));
    }

    // Validate URL with repository
    final validationResult = await repository.validateUrl(url);
    return validationResult.fold(
      (failure) => Left(failure),
      (isValid) {
        if (!isValid) {
          return Left(InvalidUrlFailure('URL validation failed'));
        }
        return repository.analyzeVideo(url);
      },
    );
  }
}
```

### Task 6: Implement StartDownloadUseCase

- **Thời gian ước tính:** 35 phút
- **Mô tả:** Triển khai business logic cho download management với parameter validation
- **File:** `lib/domain/usecases/start_download.dart`
- **Trạng thái:** [ ] TO DO

```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../entities/download_task.dart';
import '../repositories/download_repository.dart';
import '../../core/error/failures.dart';

@injectable
class StartDownloadUseCase {
  final DownloadRepository repository;
  final Uuid uuid;

  StartDownloadUseCase(this.repository, this.uuid);

  Future<Either<Failure, DownloadTask>> call({
    required String videoId,
    required String title,
    required String formatId,
    required String outputPath,
  }) async {
    // Validate parameters
    if (videoId.isEmpty) {
      return Left(ValidationFailure('Video ID cannot be empty'));
    }
    if (title.isEmpty) {
      return Left(ValidationFailure('Title cannot be empty'));
    }
    if (formatId.isEmpty) {
      return Left(ValidationFailure('Format ID cannot be empty'));
    }
    if (outputPath.isEmpty) {
      return Left(ValidationFailure('Output path cannot be empty'));
    }

    // Create download task
    final task = DownloadTask(
      id: uuid.v4(),
      videoId: videoId,
      title: title,
      formatId: formatId,
      outputPath: outputPath,
      createdAt: DateTime.now(),
    );

    // Start download
    return repository.startDownload(task);
  }
}
```

### Task 7: Implement YouTube DataSource

- **Thời gian ước tính:** 45 phút
- **Mô tả:** Triển khai YouTube API integration với youtube_explode_dart
- **File:** `lib/data/datasources/youtube_datasource.dart`
- **Trạng thái:** [ ] TO DO

```dart
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/video_info_model.dart';

abstract class YouTubeDataSource {
  Future<VideoInfoModel> getVideoInfo(String url);
  Future<bool> validateUrl(String url);
}

class YouTubeDataSourceImpl implements YouTubeDataSource {
  final YoutubeExplode _yt;

  YouTubeDataSourceImpl() : _yt = YoutubeExplode();

  @override
  Future<VideoInfoModel> getVideoInfo(String url) async {
    try {
      final video = await _yt.videos.get(url);
      final manifest = await _yt.videos.streamsClient.getManifest(url);

      final formats = manifest.muxed.map((stream) => VideoFormatModel(
        formatId: stream.videoCodec,
        quality: stream.videoQuality.toString(),
        extension: stream.container.toString(),
        bitrate: stream.bitrate.bps,
        width: stream.videoQuality.width,
        height: stream.videoQuality.height,
      )).toList();

      return VideoInfoModel(
        id: video.id.value,
        title: video.title,
        description: video.description,
        duration: video.duration,
        thumbnailUrl: video.thumbnails.highResUrl,
        formats: formats,
        url: url,
      );
    } catch (e) {
      throw Exception('Failed to get video info: $e');
    }
  }

  @override
  Future<bool> validateUrl(String url) async {
    try {
      await _yt.videos.get(url);
      return true;
    } catch (e) {
      return false;
    }
  }
}
```

### Task 8: Implement VideoInfo Data Model

- **Thời gian ước tính:** 30 phút
- **Mô tả:** Tạo VideoInfo data model với JSON serialization và factory methods
- **File:** `lib/data/models/video_info_model.dart`
- **Trạng thái:** [ ] TO DO

```dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/video_info.dart' as domain;

part 'video_info_model.g.dart';

@JsonSerializable()
class VideoInfoModel {
  final String id;
  final String title;
  final String description;
  @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
  final Duration duration;
  final String thumbnailUrl;
  final List<VideoFormatModel> formats;
  final String url;

  VideoInfoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.thumbnailUrl,
    required this.formats,
    required this.url,
  });

  factory VideoInfoModel.fromJson(Map<String, dynamic> json) =>
      _$VideoInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoInfoModelToJson(this);

  domain.VideoInfo toDomain() {
    return domain.VideoInfo(
      id: id,
      title: title,
      description: description,
      duration: duration,
      thumbnailUrl: thumbnailUrl,
      formats: formats.map((f) => f.toDomain()).toList(),
      url: url,
    );
  }

  static Duration _durationFromJson(int seconds) => Duration(seconds: seconds);
  static int _durationToJson(Duration duration) => duration.inSeconds;
}

@JsonSerializable()
class VideoFormatModel {
  final String formatId;
  final String quality;
  final String extension;
  final int? bitrate;
  final int? width;
  final int? height;

  VideoFormatModel({
    required this.formatId,
    required this.quality,
    required this.extension,
    this.bitrate,
    this.width,
    this.height,
  });

  factory VideoFormatModel.fromJson(Map<String, dynamic> json) =>
      _$VideoFormatModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoFormatModelToJson(this);

  domain.VideoFormat toDomain() {
    return domain.VideoFormat(
      formatId: formatId,
      quality: quality,
      extension: extension,
      bitrate: bitrate,
      width: width,
      height: height,
    );
  }
}
```

### Task 9: Create URL Input Widget

- **Thời gian ước tính:** 40 phút
- **Mô tả:** Tạo URL input widget với validation và real-time checking
- **File:** `lib/presentation/widgets/url_input_widget.dart`
- **Trạng thái:** [ ] TO DO

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/video_analysis/video_analysis_cubit.dart';

class UrlInputWidget extends StatefulWidget {
  final Function(String) onUrlSubmitted;

  const UrlInputWidget({
    Key? key,
    required this.onUrlSubmitted,
  }) : super(key: key);

  @override
  State<UrlInputWidget> createState() => _UrlInputWidgetState();
}

class _UrlInputWidgetState extends State<UrlInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isValidUrl = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_validateUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validateUrl() {
    final url = _controller.text.trim();
    setState(() {
      _isValidUrl = url.isNotEmpty && _isValidYouTubeUrl(url);
    });
  }

  bool _isValidYouTubeUrl(String url) {
    final youtubeRegex = RegExp(
      r'^(https?://)?(www\.)?(youtube\.com|youtu\.be)/.+$',
      caseSensitive: false,
    );
    return youtubeRegex.hasMatch(url);
  }

  void _submitUrl() {
    final url = _controller.text.trim();
    if (_isValidUrl) {
      widget.onUrlSubmitted(url);
      _controller.clear();
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoAnalysisCubit, VideoAnalysisState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                labelText: 'Nhập URL YouTube',
                hintText: 'https://www.youtube.com/watch?v=...',
                prefixIcon: const Icon(Icons.link),
                suffixIcon: _isValidUrl
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.error, color: Colors.red),
                border: const OutlineInputBorder(),
                errorText: state is VideoAnalysisError ? state.message : null,
              ),
              onSubmitted: (_) => _submitUrl(),
              enabled: state is! VideoAnalysisLoading,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isValidUrl && state is! VideoAnalysisLoading
                  ? _submitUrl
                  : null,
              icon: state is VideoAnalysisLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(
                state is VideoAnalysisLoading ? 'Đang phân tích...' : 'Phân tích Video',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        );
      },
    );
  }
}
```

### Task 10: Implement Video Analysis Cubit

- **Thời gian ước tính:** 35 phút
- **Mô tả:** Triển khai state management cho video analysis với loading states và error handling
- **File:** `lib/presentation/bloc/video_analysis/video_analysis_cubit.dart`
- **Trạng thái:** [ ] TO DO

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/video_info.dart';
import '../../../domain/usecases/analyze_video.dart';

part 'video_analysis_state.dart';

@injectable
class VideoAnalysisCubit extends Cubit<VideoAnalysisState> {
  final AnalyzeVideoUseCase _analyzeVideoUseCase;

  VideoAnalysisCubit(this._analyzeVideoUseCase) : super(VideoAnalysisInitial());

  Future<void> analyzeVideo(String url) async {
    emit(VideoAnalysisLoading());

    final result = await _analyzeVideoUseCase(url);

    result.fold(
      (failure) => emit(VideoAnalysisError(failure.message)),
      (videoInfo) => emit(VideoAnalysisSuccess(videoInfo)),
    );
  }

  void reset() {
    emit(VideoAnalysisInitial());
  }
}
```

**File:** `lib/presentation/bloc/video_analysis/video_analysis_state.dart`

```dart
part of 'video_analysis_cubit.dart';

abstract class VideoAnalysisState extends Equatable {
  const VideoAnalysisState();

  @override
  List<Object?> get props => [];
}

class VideoAnalysisInitial extends VideoAnalysisState {}

class VideoAnalysisLoading extends VideoAnalysisState {}

class VideoAnalysisSuccess extends VideoAnalysisState {
  final VideoInfo videoInfo;

  const VideoAnalysisSuccess(this.videoInfo);

  @override
  List<Object?> get props => [videoInfo];
}

class VideoAnalysisError extends VideoAnalysisState {
  final String message;

  const VideoAnalysisError(this.message);

  @override
  List<Object?> get props => [message];
}
```

---

## 🎯 Expected Results

Sau khi hoàn thành tất cả 10 tasks, kết quả mong đợi:

1. **Domain Layer Foundation:** VideoInfo và DownloadTask entities hoàn chỉnh với validation
2. **Repository Interfaces:** VideoRepository và DownloadRepository với proper error handling
3. **Business Logic:** AnalyzeVideoUseCase và StartDownloadUseCase với parameter validation
4. **Data Layer:** YouTube API integration với youtube_explode_dart
5. **Presentation Layer:** URL input widget với real-time validation và video analysis state management

**Deliverables đạt được:**

- ✅ Foundation cho video analysis và download management
- ✅ URL input functionality với validation hoàn chỉnh
- ✅ Clean Architecture pattern được tuân thủ
- ✅ State management cho video analysis flow
- ✅ Error handling cho network failures và invalid inputs

---

## 🔄 Next Steps

Sau khi hoàn thành Sprint 1.1:

1. **Integration Testing:** Kiểm tra tính năng URL input và video analysis
2. **Sprint 1.2:** Bắt đầu triển khai video analysis UI và format selection
3. **Repository Implementation:** Implement concrete classes cho VideoRepository và DownloadRepository
4. **Error Handling Enhancement:** Cải thiện error messages và user feedback
5. **Unit Tests:** Viết unit tests cho use cases và entities

---

## 📝 Notes

### Kiến trúc và Công nghệ:

- **Clean Architecture:** Tuân thủ strict separation giữa Domain, Data, và Presentation layers
- **Dependency Injection:** Sử dụng get_it và injectable cho loose coupling
- **State Management:** flutter_bloc cho video analysis state management
- **Validation:** URL format validation với regex patterns

### Dependencies cần thêm vào pubspec.yaml:

```yaml
dependencies:
  youtube_explode_dart: ^1.12.4
  equatable: ^2.0.5
  dartz: ^0.10.1
  injectable: ^2.3.2
  get_it: ^7.6.4
  flutter_bloc: ^8.1.3
  uuid: ^4.2.1
  json_annotation: ^4.8.1

dev_dependencies:
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  injectable_generator: ^2.4.1
```

### Ràng buộc pháp lý:

- Tuân thủ YouTube Terms of Service
- Chỉ sử dụng cho mục đích cá nhân
- Không vi phạm DMCA hoặc copyright laws

### Các bước triển khai:

1. Chạy `flutter pub get` để cài đặt dependencies
2. Chạy `flutter packages pub run build_runner build` để generate code
3. Implement các entities và interfaces theo thứ tự ưu tiên
4. Test từng component trước khi chuyển sang task tiếp theo
5. Đảm bảo error handling được implement đầy đủ
