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
