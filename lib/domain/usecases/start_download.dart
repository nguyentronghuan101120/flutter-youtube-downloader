import '../entities/download_task.dart';
import '../repositories/download_repository.dart';
import '../repositories/storage_repository.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

class StartDownload {
  final DownloadRepository downloadRepository;
  final StorageRepository storageRepository;

  StartDownload({
    required this.downloadRepository,
    required this.storageRepository,
  });

  Future<Either<Failure, Stream<DownloadTask>>> call(DownloadTask task) async {
    try {
      // Kiểm tra quyền storage
      final hasPermission = await storageRepository.hasStoragePermission();
      if (!hasPermission) {
        return const Left(PermissionFailure('Storage permission required'));
      }

      // Kiểm tra dung lượng trống
      final hasSpace = await storageRepository.hasEnoughSpace(task.totalBytes);
      if (!hasSpace) {
        return const Left(StorageFailure('Insufficient storage space'));
      }

      // Tạo thư mục nếu cần
      await storageRepository.createDirectory(task.destinationPath);

      // Bắt đầu tải xuống
      final downloadStream = downloadRepository.downloadVideo(task);
      return Right(downloadStream);
    } catch (e) {
      return Left(DownloadFailure(e.toString()));
    }
  }
}
