import 'package:injectable/injectable.dart';
import '../../entities/download_task.dart';
import '../../../core/constants/download_status.dart';
import '../../repositories/download_repository.dart';
import '../../../core/usecases/base_usecase.dart';
import '../../../core/result/result.dart';

@injectable
class StartDownloadUseCase
    implements BaseUseCase<Result<DownloadTask>, StartDownloadParams> {
  final DownloadRepository _downloadRepository;

  const StartDownloadUseCase({required DownloadRepository downloadRepository})
    : _downloadRepository = downloadRepository;

  @override
  Future<Result<DownloadTask>> execute(StartDownloadParams params) async {
    try {
      // Validate parameters
      final validationResult = _validateParameters(params);
      if (validationResult.isFailure) {
        return Result.failure(validationResult.errorMessage!);
      }

      // Create download task
      final task = DownloadTask(
        id: _generateTaskId(),
        videoId: params.videoId,
        title: params.title,
        url: params.url,
        format: params.format,
        quality: params.quality,
        outputPath: params.outputPath,
        status: DownloadStatus.pending,
        bytesDownloaded: 0,
        totalBytes: 0,
        progress: 0.0,
        createdAt: DateTime.now(),
      );

      // Start download using repository with progress tracking
      return await _downloadRepository.startDownload(
        task,
        onProgress: params.onProgress,
      );
    } catch (e) {
      return Result.failure('Failed to start download: $e');
    }
  }

  /// Validates download parameters
  Result<void> _validateParameters(StartDownloadParams params) {
    // Validate video ID
    if (params.videoId.isEmpty) {
      return Result.failure('Video ID cannot be empty');
    }

    // Validate title
    if (params.title.isEmpty) {
      return Result.failure('Video title cannot be empty');
    }

    // Validate URL
    if (params.url.isEmpty) {
      return Result.failure('Video URL cannot be empty');
    }

    // Validate format
    if (!_isValidFormat(params.format)) {
      return Result.failure(
        'Invalid format: ${params.format}. Supported formats: ${_getSupportedFormats().join(', ')}',
      );
    }

    // Validate quality
    if (!_isValidQuality(params.quality)) {
      return Result.failure(
        'Invalid quality: ${params.quality}. Supported qualities: ${_getSupportedQualities().join(', ')}',
      );
    }

    // Validate output path
    if (params.outputPath.isEmpty) {
      return Result.failure('Output path cannot be empty');
    }

    return const Result.success(null);
  }

  /// Checks if format is supported
  bool _isValidFormat(String format) {
    final supportedFormats = _getSupportedFormats();
    return supportedFormats.contains(format.toLowerCase());
  }

  /// Checks if quality is supported
  bool _isValidQuality(String quality) {
    final supportedQualities = _getSupportedQualities();
    return supportedQualities.contains(quality.toLowerCase());
  }

  /// Returns list of supported formats
  List<String> _getSupportedFormats() {
    return ['mp4', 'mp3', 'webm', 'm4a', 'ogg'];
  }

  /// Returns list of supported qualities
  List<String> _getSupportedQualities() {
    return ['144p', '240p', '360p', '480p', '720p', '1080p', '1440p', '2160p'];
  }

  /// Generates a unique task ID
  String _generateTaskId() {
    return 'download_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}';
  }
}

class StartDownloadParams {
  final String videoId;
  final String title;
  final String url;
  final String format;
  final String quality;
  final String outputPath;
  final Function(double progress, int bytesDownloaded, int totalBytes)?
  onProgress;

  const StartDownloadParams({
    required this.videoId,
    required this.title,
    required this.url,
    required this.format,
    required this.quality,
    required this.outputPath,
    this.onProgress,
  });
}
