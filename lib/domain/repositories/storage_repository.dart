import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

abstract class StorageRepository {
  /// Gets the download directory path
  Future<Either<Failure, String>> getDownloadDirectory();

  /// Creates a new directory
  Future<Either<Failure, String>> createDirectory(String path);

  /// Checks if a file exists
  Future<Either<Failure, bool>> fileExists(String filePath);

  /// Gets file size in bytes
  Future<Either<Failure, int>> getFileSize(String filePath);

  /// Deletes a file
  Future<Either<Failure, bool>> deleteFile(String filePath);

  /// Moves a file to a new location
  Future<Either<Failure, String>> moveFile(
    String sourcePath,
    String destinationPath,
  );

  /// Copies a file to a new location
  Future<Either<Failure, String>> copyFile(
    String sourcePath,
    String destinationPath,
  );

  /// Lists all files in a directory
  Future<Either<Failure, List<String>>> listFiles(String directoryPath);

  /// Gets available storage space in bytes
  Future<Either<Failure, int>> getAvailableStorageSpace();

  /// Gets total storage space in bytes
  Future<Either<Failure, int>> getTotalStorageSpace();

  /// Organizes downloaded files by type
  Future<Either<Failure, bool>> organizeFiles();

  /// Cleans up temporary files
  Future<Either<Failure, bool>> cleanupTempFiles();

  /// Gets file information
  Future<Either<Failure, FileInfo>> getFileInfo(String filePath);
}

/// File information data class
class FileInfo {
  final String path;
  final String name;
  final int size;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final bool isDirectory;

  FileInfo({
    required this.path,
    required this.name,
    required this.size,
    required this.createdAt,
    required this.modifiedAt,
    required this.isDirectory,
  });
}
