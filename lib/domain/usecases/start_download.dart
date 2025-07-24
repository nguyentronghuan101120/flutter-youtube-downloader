import 'package:injectable/injectable.dart';
import '../entities/download_task.dart';
import '../repositories/download_repository.dart';

@injectable
class StartDownloadUseCase {
  final DownloadRepository _downloadRepository;

  const StartDownloadUseCase({required DownloadRepository downloadRepository})
    : _downloadRepository = downloadRepository;

  /// Starts a new download task with validation
  ///
  /// [videoId] - The YouTube video ID
  /// [title] - The video title
  /// [url] - The video URL
  /// [format] - The desired format (mp4, mp3, etc.)
  /// [quality] - The desired quality (720p, 1080p, etc.)
  /// [outputPath] - The output file path
  /// Returns the created download task
  /// Throws [Exception] if parameters are invalid or download fails to start
  Future<DownloadTask> execute({
    required String videoId,
    required String title,
    required String url,
    required String format,
    required String quality,
    required String outputPath,
  }) async {
    try {
      // Validate parameters
      _validateParameters(
        videoId: videoId,
        title: title,
        url: url,
        format: format,
        quality: quality,
        outputPath: outputPath,
      );

      // Create download task
      final task = DownloadTask(
        id: _generateTaskId(),
        videoId: videoId,
        title: title,
        url: url,
        format: format,
        quality: quality,
        outputPath: outputPath,
        status: DownloadStatus.pending,
        bytesDownloaded: 0,
        totalBytes: 0,
        progress: 0.0,
        createdAt: DateTime.now(),
      );

      // Start download using repository
      final startedTask = await _downloadRepository.startDownload(task);

      return startedTask;
    } catch (e) {
      // Re-throw with more descriptive error message
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to start download: $e');
    }
  }

  /// Validates download parameters
  void _validateParameters({
    required String videoId,
    required String title,
    required String url,
    required String format,
    required String quality,
    required String outputPath,
  }) {
    // Validate video ID
    if (videoId.isEmpty) {
      throw Exception('Video ID cannot be empty');
    }

    // Validate title
    if (title.isEmpty) {
      throw Exception('Video title cannot be empty');
    }

    // Validate URL
    if (url.isEmpty) {
      throw Exception('Video URL cannot be empty');
    }

    // Validate format
    if (!_isValidFormat(format)) {
      throw Exception(
        'Invalid format: $format. Supported formats: ${_getSupportedFormats().join(', ')}',
      );
    }

    // Validate quality
    if (!_isValidQuality(quality)) {
      throw Exception(
        'Invalid quality: $quality. Supported qualities: ${_getSupportedQualities().join(', ')}',
      );
    }

    // Validate output path
    if (outputPath.isEmpty) {
      throw Exception('Output path cannot be empty');
    }
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
