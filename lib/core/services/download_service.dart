import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/download_task.dart';

/// Download progress data
class DownloadProgress {
  final int bytesDownloaded;
  final int totalBytes;
  final double percentage;
  final double speed; // bytes per second
  final Duration estimatedTimeRemaining;

  DownloadProgress({
    required this.bytesDownloaded,
    required this.totalBytes,
    required this.percentage,
    required this.speed,
    required this.estimatedTimeRemaining,
  });
}

class DownloadService {
  final Dio _dio;
  final Map<String, bool> _cancelledDownloads = {};
  final Map<String, StreamController<DownloadProgress>> _progressControllers =
      {};

  DownloadService({Dio? dio}) : _dio = dio ?? Dio();

  /// Starts a download with progress tracking
  Future<DownloadTask> startDownload(
    DownloadTask task,
    void Function(DownloadProgress progress)? onProgress,
  ) async {
    try {
      _cancelledDownloads[task.id] = false;

      final progressController = StreamController<DownloadProgress>.broadcast();
      _progressControllers[task.id] = progressController;

      // Get download directory
      final downloadDir = await _getDownloadDirectory();
      final fileName = _generateFileName(task.title, task.formatId);
      final outputPath = '$downloadDir/$fileName';

      // Update task with output path
      final updatedTask = task.copyWith(outputPath: outputPath);

      // Start download
      final result = await _performDownload(updatedTask, onProgress);

      // Cleanup
      _cancelledDownloads.remove(task.id);
      await progressController.close();
      _progressControllers.remove(task.id);

      return result;
    } catch (e) {
      return task.copyWith(
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  /// Resumes a paused download
  Future<DownloadTask> resumeDownload(
    DownloadTask task,
    void Function(DownloadProgress progress)? onProgress,
  ) async {
    try {
      final file = File(task.outputPath);
      int existingBytes = 0;

      // Check if partial file exists
      if (await file.exists()) {
        existingBytes = await file.length();
      }

      // Resume from existing position
      final updatedTask = task.copyWith(
        bytesDownloaded: existingBytes,
        status: DownloadStatus.downloading,
      );

      return await startDownload(updatedTask, onProgress);
    } catch (e) {
      return task.copyWith(
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  /// Cancels a download
  void cancelDownload(String taskId) {
    _cancelledDownloads[taskId] = true;
  }

  /// Pauses a download
  Future<DownloadTask> pauseDownload(DownloadTask task) async {
    _cancelledDownloads[task.id] = true;

    return task.copyWith(status: DownloadStatus.paused);
  }

  /// Gets download progress stream
  Stream<DownloadProgress> getProgressStream(String taskId) {
    final controller = _progressControllers[taskId];
    if (controller != null) {
      return controller.stream;
    }
    return Stream.empty();
  }

  /// Internal method to perform the actual download
  Future<DownloadTask> _performDownload(
    DownloadTask task,
    void Function(DownloadProgress progress)? onProgress,
  ) async {
    try {
      final file = File(task.outputPath);
      final tempFile = await _createTempFile('${task.id}_temp');

      // Get file size if not already known
      int totalBytes = task.totalBytes;
      if (totalBytes == 0) {
        final response = await _dio.head(task.formatId);
        totalBytes = int.parse(response.headers.value('content-length') ?? '0');
      }

      // Start download with progress tracking
      final startTime = DateTime.now();
      int lastBytesDownloaded = task.bytesDownloaded;

      await _dio.download(
        task.formatId,
        tempFile.path,
        onReceiveProgress: (received, total) {
          if (_cancelledDownloads[task.id] == true) {
            throw Exception('Download cancelled');
          }

          final currentBytes = received + task.bytesDownloaded;
          final percentage = totalBytes > 0
              ? (currentBytes / totalBytes) * 100
              : 0.0;

          // Calculate speed
          final elapsed = DateTime.now().difference(startTime).inSeconds;
          final speed = elapsed > 0 ? currentBytes / elapsed : 0.0;

          // Calculate estimated time remaining
          final remainingBytes = totalBytes - currentBytes;
          final estimatedSeconds = speed > 0 ? remainingBytes / speed : 0;
          final estimatedTime = Duration(seconds: estimatedSeconds.toInt());

          final progress = DownloadProgress(
            bytesDownloaded: currentBytes,
            totalBytes: totalBytes,
            percentage: percentage,
            speed: speed,
            estimatedTimeRemaining: estimatedTime,
          );

          // Notify progress listeners
          onProgress?.call(progress);
          _progressControllers[task.id]?.add(progress);

          lastBytesDownloaded = currentBytes;
        },
        options: Options(
          headers: {'Range': 'bytes=${task.bytesDownloaded}-'},
          responseType: ResponseType.bytes,
        ),
      );

      // Move temp file to final location
      await tempFile.rename(task.outputPath);

      return task.copyWith(
        status: DownloadStatus.completed,
        bytesDownloaded: totalBytes,
        totalBytes: totalBytes,
        completedAt: DateTime.now(),
      );
    } catch (e) {
      if (_cancelledDownloads[task.id] == true) {
        return task.copyWith(status: DownloadStatus.cancelled);
      }

      return task.copyWith(
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  /// Gets the download directory
  Future<String> _getDownloadDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${directory.path}/downloads');

    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    return downloadDir.path;
  }

  /// Creates a temporary file
  Future<File> _createTempFile(String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$fileName');

    if (await tempFile.exists()) {
      await tempFile.delete();
    }

    return tempFile;
  }

  /// Generates a safe filename
  String _generateFileName(String title, String formatId) {
    final extension = _getFileExtension(formatId);
    final safeTitle = title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    return '${safeTitle}_${DateTime.now().millisecondsSinceEpoch}$extension';
  }

  /// Gets file extension from format ID
  String _getFileExtension(String formatId) {
    if (formatId.contains('mp4')) return '.mp4';
    if (formatId.contains('webm')) return '.webm';
    if (formatId.contains('mp3')) return '.mp3';
    if (formatId.contains('aac')) return '.aac';
    if (formatId.contains('ogg')) return '.ogg';
    return '.mp4'; // default
  }

  /// Disposes all resources
  void dispose() {
    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();
    _cancelledDownloads.clear();
  }
}
