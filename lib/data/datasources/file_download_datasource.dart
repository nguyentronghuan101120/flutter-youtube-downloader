import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/download_task.dart';

abstract class FileDownloadDataSource {
  /// Downloads a file with resume capability
  Future<DownloadTask> downloadFile(
    DownloadTask task,
    void Function(int bytesDownloaded, int totalBytes) onProgress,
  );

  /// Resumes a partially downloaded file
  Future<DownloadTask> resumeDownload(
    DownloadTask task,
    void Function(int bytesDownloaded, int totalBytes) onProgress,
  );

  /// Gets the download directory
  Future<String> getDownloadDirectory();

  /// Checks if a file exists and gets its size
  Future<int> getFileSize(String filePath);

  /// Creates a temporary file for download
  Future<File> createTempFile(String fileName);
}

class FileDownloadDataSourceImpl implements FileDownloadDataSource {
  final Dio _dio;
  final int _chunkSize = 1024 * 1024; // 1MB chunks

  FileDownloadDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<DownloadTask> downloadFile(
    DownloadTask task,
    void Function(int bytesDownloaded, int totalBytes) onProgress,
  ) async {
    try {
      final file = File(task.outputPath);
      final tempFile = await createTempFile('${task.id}_temp');

      // Get file size if not already known
      int totalBytes = task.totalBytes;
      if (totalBytes == 0) {
        final response = await _dio.head(task.formatId);
        totalBytes = int.parse(response.headers.value('content-length') ?? '0');
      }

      // Start download
      await _dio.download(
        task.formatId,
        tempFile.path,
        onReceiveProgress: (received, total) {
          final progress = received + task.bytesDownloaded;
          onProgress(progress, totalBytes);
        },
        options: Options(headers: {'Range': 'bytes=${task.bytesDownloaded}-'}),
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
      return task.copyWith(
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  @override
  Future<DownloadTask> resumeDownload(
    DownloadTask task,
    void Function(int bytesDownloaded, int totalBytes) onProgress,
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

      return await downloadFile(updatedTask, onProgress);
    } catch (e) {
      return task.copyWith(
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  @override
  Future<String> getDownloadDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${directory.path}/downloads');

    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    return downloadDir.path;
  }

  @override
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<File> createTempFile(String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$fileName');

    if (await tempFile.exists()) {
      await tempFile.delete();
    }

    return tempFile;
  }
}
