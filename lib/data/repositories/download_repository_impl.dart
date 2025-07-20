import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/download_task.dart';
import '../../domain/repositories/download_repository.dart';
import '../../core/error/failures.dart';
import '../datasources/file_download_datasource.dart';

@Injectable(as: DownloadRepository)
class DownloadRepositoryImpl implements DownloadRepository {
  final FileDownloadDataSource _fileDownloadDataSource;
  final Map<String, DownloadTask> _downloadTasks = {};
  final Map<String, StreamController<DownloadTask>> _progressControllers = {};

  DownloadRepositoryImpl({
    required FileDownloadDataSource fileDownloadDataSource,
  }) : _fileDownloadDataSource = fileDownloadDataSource;

  @override
  Future<Either<Failure, DownloadTask>> startDownload(DownloadTask task) async {
    try {
      // Add task to tracking
      _downloadTasks[task.id] = task.copyWith(
        status: DownloadStatus.downloading,
      );

      // Create progress controller
      final controller = StreamController<DownloadTask>.broadcast();
      _progressControllers[task.id] = controller;

      // Start download in background
      _downloadFile(task, controller);

      return Right(_downloadTasks[task.id]!);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DownloadTask>> pauseDownload(String taskId) async {
    try {
      final task = _downloadTasks[taskId];
      if (task == null) {
        return Left(ServerFailure('Download task not found'));
      }

      final updatedTask = task.copyWith(status: DownloadStatus.paused);
      _downloadTasks[taskId] = updatedTask;

      return Right(updatedTask);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DownloadTask>> resumeDownload(String taskId) async {
    try {
      final task = _downloadTasks[taskId];
      if (task == null) {
        return Left(ServerFailure('Download task not found'));
      }

      if (task.status != DownloadStatus.paused) {
        return Left(ServerFailure('Download is not paused'));
      }

      final updatedTask = task.copyWith(status: DownloadStatus.downloading);
      _downloadTasks[taskId] = updatedTask;

      // Resume download
      final controller = _progressControllers[taskId];
      if (controller != null) {
        _downloadFile(updatedTask, controller);
      }

      return Right(updatedTask);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> cancelDownload(String taskId) async {
    try {
      final task = _downloadTasks[taskId];
      if (task == null) {
        return Left(ServerFailure('Download task not found'));
      }

      // Update status
      final updatedTask = task.copyWith(status: DownloadStatus.cancelled);
      _downloadTasks[taskId] = updatedTask;

      // Close progress controller
      final controller = _progressControllers[taskId];
      if (controller != null) {
        await controller.close();
        _progressControllers.remove(taskId);
      }

      return Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DownloadTask>>> getDownloads() async {
    try {
      return Right(_downloadTasks.values.toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DownloadTask>> getDownload(String taskId) async {
    try {
      final task = _downloadTasks[taskId];
      if (task == null) {
        return Left(ServerFailure('Download task not found'));
      }
      return Right(task);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DownloadTask>> updateProgress(
    String taskId,
    int bytesDownloaded,
    int totalBytes,
  ) async {
    try {
      final task = _downloadTasks[taskId];
      if (task == null) {
        return Left(ServerFailure('Download task not found'));
      }

      final updatedTask = task.copyWith(
        bytesDownloaded: bytesDownloaded,
        totalBytes: totalBytes,
      );
      _downloadTasks[taskId] = updatedTask;

      // Notify progress listeners
      final controller = _progressControllers[taskId];
      if (controller != null && !controller.isClosed) {
        controller.add(updatedTask);
      }

      return Right(updatedTask);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Internal method to handle file download
  Future<void> _downloadFile(
    DownloadTask task,
    StreamController<DownloadTask> controller,
  ) async {
    try {
      final result = await _fileDownloadDataSource.downloadFile(task, (
        bytesDownloaded,
        totalBytes,
      ) {
        // Update progress
        updateProgress(task.id, bytesDownloaded, totalBytes);
      });

      // Update final status
      _downloadTasks[task.id] = result;

      // Notify completion
      if (!controller.isClosed) {
        controller.add(result);
        if (result.isCompleted || result.isFailed) {
          await controller.close();
          _progressControllers.remove(task.id);
        }
      }
    } catch (e) {
      final failedTask = task.copyWith(
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
      );
      _downloadTasks[task.id] = failedTask;

      if (!controller.isClosed) {
        controller.add(failedTask);
        await controller.close();
        _progressControllers.remove(task.id);
      }
    }
  }

  /// Get progress stream for a download task
  Stream<DownloadTask> getProgressStream(String taskId) {
    final controller = _progressControllers[taskId];
    if (controller != null) {
      return controller.stream;
    }
    return Stream.empty();
  }

  /// Dispose all resources
  void dispose() {
    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();
    _downloadTasks.clear();
  }
}
