import '../entities/download_task.dart';
import '../repositories/download_repository.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

class GetActiveDownloads {
  final DownloadRepository repository;

  GetActiveDownloads({required this.repository});

  Future<Either<Failure, List<DownloadTask>>> call() async {
    try {
      final downloads = await repository.getActiveDownloads();
      return Right(downloads);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}

class GetCompletedDownloads {
  final DownloadRepository repository;

  GetCompletedDownloads({required this.repository});

  Future<Either<Failure, List<DownloadTask>>> call() async {
    try {
      final downloads = await repository.getCompletedDownloads();
      return Right(downloads);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}

class GetQueuedDownloads {
  final DownloadRepository repository;

  GetQueuedDownloads({required this.repository});

  Future<Either<Failure, List<DownloadTask>>> call() async {
    try {
      final downloads = await repository.getQueuedDownloads();
      return Right(downloads);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
