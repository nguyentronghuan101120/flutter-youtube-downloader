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
      return Left(InvalidInputFailure('Video ID cannot be empty'));
    }
    if (title.isEmpty) {
      return Left(InvalidInputFailure('Title cannot be empty'));
    }
    if (formatId.isEmpty) {
      return Left(InvalidInputFailure('Format ID cannot be empty'));
    }
    if (outputPath.isEmpty) {
      return Left(InvalidInputFailure('Output path cannot be empty'));
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
