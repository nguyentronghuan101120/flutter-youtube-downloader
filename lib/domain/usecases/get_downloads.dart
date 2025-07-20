import 'package:injectable/injectable.dart';
import '../entities/download_task.dart';
import '../repositories/download_repository.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

@injectable
class GetActiveDownloads {
  final DownloadRepository repository;

  GetActiveDownloads(this.repository);

  Future<Either<Failure, List<DownloadTask>>> call() async {
    try {
      final downloads = await repository.getActiveDownloads();
      return Right(downloads);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}

@injectable
class GetCompletedDownloads {
  final DownloadRepository repository;

  GetCompletedDownloads(this.repository);

  Future<Either<Failure, List<DownloadTask>>> call() async {
    try {
      final downloads = await repository.getCompletedDownloads();
      return Right(downloads);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}

@injectable
class GetQueuedDownloads {
  final DownloadRepository repository;

  GetQueuedDownloads(this.repository);

  Future<Either<Failure, List<DownloadTask>>> call() async {
    try {
      final downloads = await repository.getQueuedDownloads();
      return Right(downloads);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
