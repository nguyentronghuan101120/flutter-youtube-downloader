import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/repositories/storage_repository.dart';
import '../../core/error/failures.dart';

@Injectable(as: StorageRepository)
class StorageRepositoryImpl implements StorageRepository {
  @override
  Future<Either<Failure, String>> getDownloadDirectory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${directory.path}/downloads');

      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      return Right(downloadDir.path);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createDirectory(String path) async {
    try {
      final directory = Directory(path);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return Right(path);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return Right(await file.exists());
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return Right(await file.length());
      }
      return Right(0);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return Right(true);
      }
      return Right(false);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> moveFile(
    String sourcePath,
    String destinationPath,
  ) async {
    try {
      final sourceFile = File(sourcePath);
      final destinationFile = File(destinationPath);

      if (!await sourceFile.exists()) {
        return Left(StorageFailure('Source file does not exist'));
      }

      // Create destination directory if it doesn't exist
      final destinationDir = Directory(destinationFile.parent.path);
      if (!await destinationDir.exists()) {
        await destinationDir.create(recursive: true);
      }

      await sourceFile.rename(destinationPath);
      return Right(destinationPath);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> copyFile(
    String sourcePath,
    String destinationPath,
  ) async {
    try {
      final sourceFile = File(sourcePath);
      final destinationFile = File(destinationPath);

      if (!await sourceFile.exists()) {
        return Left(StorageFailure('Source file does not exist'));
      }

      // Create destination directory if it doesn't exist
      final destinationDir = Directory(destinationFile.parent.path);
      if (!await destinationDir.exists()) {
        await destinationDir.create(recursive: true);
      }

      await sourceFile.copy(destinationPath);
      return Right(destinationPath);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> listFiles(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        return Right([]);
      }

      final files = await directory.list().toList();
      final filePaths = files
          .where((entity) => entity is File)
          .map((file) => file.path)
          .toList();

      return Right(filePaths);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getAvailableStorageSpace() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final stat = await directory.stat();
      return Right(stat.size);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalStorageSpace() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final stat = await directory.stat();
      return Right(stat.size);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> organizeFiles() async {
    try {
      final downloadDirResult = await getDownloadDirectory();
      return downloadDirResult.fold((failure) => Left(failure), (
        downloadDir,
      ) async {
        final filesResult = await listFiles(downloadDir);
        return filesResult.fold((failure) => Left(failure), (files) async {
          for (final filePath in files) {
            final fileInfoResult = await getFileInfo(filePath);
            fileInfoResult.fold((failure) => null, (info) async {
              final extension = _getFileExtension(info.name);
              final category = _getFileCategory(extension);

              if (category != null) {
                final categoryDir = '$downloadDir/$category';
                await createDirectory(categoryDir);

                final newPath = '$categoryDir/${info.name}';
                await moveFile(filePath, newPath);
              }
            });
          }
          return Right(true);
        });
      });
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFilesResult = await listFiles(tempDir.path);

      return tempFilesResult.fold((failure) => Left(failure), (
        tempFiles,
      ) async {
        for (final filePath in tempFiles) {
          if (filePath.contains('_temp') || filePath.contains('.tmp')) {
            await deleteFile(filePath);
          }
        }
        return Right(true);
      });
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FileInfo>> getFileInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return Left(StorageFailure('File does not exist'));
      }

      final stat = await file.stat();
      final name = filePath.split('/').last;

      return Right(
        FileInfo(
          path: filePath,
          name: name,
          size: stat.size,
          createdAt: stat.changed,
          modifiedAt: stat.modified,
          isDirectory: false,
        ),
      );
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  /// Gets file extension from filename
  String _getFileExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return '';
  }

  /// Gets file category based on extension
  String? _getFileCategory(String extension) {
    switch (extension) {
      case 'mp4':
      case 'webm':
      case 'avi':
      case 'mkv':
        return 'videos';
      case 'mp3':
      case 'aac':
      case 'ogg':
      case 'wav':
        return 'audio';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return 'images';
      case 'pdf':
      case 'doc':
      case 'docx':
      case 'txt':
        return 'documents';
      default:
        return 'others';
    }
  }
}
