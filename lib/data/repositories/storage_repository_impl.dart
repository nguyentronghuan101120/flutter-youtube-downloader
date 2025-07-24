import 'package:injectable/injectable.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;
import '../../domain/repositories/storage_repository.dart';

@Injectable(as: StorageRepository)
class StorageRepositoryImpl implements StorageRepository {
  @override
  Future<String> getDefaultDownloadPath() async {
    try {
      // For Android, use the system Downloads directory
      // This should point to /storage/emulated/0/Download/
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        // Try to get the system Downloads directory directly
        final downloadsDir = Directory('/storage/emulated/0/Download');

        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        developer.log(
          '[storage_repository_impl.dart] - Using system downloads: ${downloadsDir.path}',
        );
        return downloadsDir.path;
      }

      // Fallback to app documents directory
      final documentsDir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${documentsDir.path}/downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      developer.log(
        '[storage_repository_impl.dart] - Using app documents downloads: ${downloadsDir.path}',
      );
      return downloadsDir.path;
    } catch (e) {
      developer.log(
        '[storage_repository_impl.dart] - Error getting download path: $e',
      );
      // Final fallback to temporary directory
      final tempDir = await getTemporaryDirectory();
      return tempDir.path;
    }
  }

  @override
  Future<String> getTempPath() async {
    try {
      final tempDir = await getTemporaryDirectory();
      developer.log(
        '[storage_repository_impl.dart] - Temp path: ${tempDir.path}',
      );
      return tempDir.path;
    } catch (e) {
      developer.log(
        '[storage_repository_impl.dart] - Error getting temp path: $e',
      );
      throw Exception('Failed to get temp path: $e');
    }
  }

  @override
  Future<bool> hasStoragePermission() async {
    try {
      // For Android 10+ (API 29+), we don't need explicit permission for app-specific storage
      // For older versions, we'll assume permission is granted if we can access external storage
      final externalDir = await getExternalStorageDirectory();
      return externalDir != null;
    } catch (e) {
      developer.log(
        '[storage_repository_impl.dart] - Error checking storage permission: $e',
      );
      return false;
    }
  }

  @override
  Future<bool> requestStoragePermission() async {
    try {
      // For now, we'll assume permission is granted if we can access external storage
      // In a real app, you would use permission_handler package to request permissions
      final externalDir = await getExternalStorageDirectory();
      return externalDir != null;
    } catch (e) {
      developer.log(
        '[storage_repository_impl.dart] - Error requesting storage permission: $e',
      );
      return false;
    }
  }

  @override
  Future<int> getAvailableSpace() async {
    try {
      final downloadPath = await getDefaultDownloadPath();
      final dir = Directory(downloadPath);
      if (await dir.exists()) {
        // This is a simplified implementation
        // In a real app, you would use platform-specific code to get actual free space
        return 1024 * 1024 * 1024; // Assume 1GB available
      }
      return 0;
    } catch (e) {
      developer.log(
        '[storage_repository_impl.dart] - Error getting available space: $e',
      );
      return 0;
    }
  }

  @override
  Future<bool> hasEnoughSpace(int requiredBytes) async {
    try {
      final availableSpace = await getAvailableSpace();
      return availableSpace >= requiredBytes;
    } catch (e) {
      developer.log(
        '[storage_repository_impl.dart] - Error checking space: $e',
      );
      return false;
    }
  }

  @override
  Future<void> createDirectory(String path) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
        developer.log(
          '[storage_repository_impl.dart] - Created directory: $path',
        );
      }
    } catch (e) {
      developer.log(
        '[storage_repository_impl.dart] - Error creating directory: $e',
      );
      throw Exception('Failed to create directory: $e');
    }
  }

  @override
  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      developer.log(
        '[storage_repository_impl.dart] - Error checking file exists: $e',
      );
      return false;
    }
  }

  @override
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        developer.log(
          '[storage_repository_impl.dart] - Deleted file: $filePath',
        );
      }
    } catch (e) {
      developer.log('[storage_repository_impl.dart] - Error deleting file: $e');
      throw Exception('Failed to delete file: $e');
    }
  }

  @override
  Future<void> moveFile(String sourcePath, String destinationPath) async {
    try {
      final sourceFile = File(sourcePath);
      final destFile = File(destinationPath);

      if (await sourceFile.exists()) {
        // Create destination directory if it doesn't exist
        final destDir = destFile.parent;
        if (!await destDir.exists()) {
          await destDir.create(recursive: true);
        }

        await sourceFile.rename(destinationPath);
        developer.log(
          '[storage_repository_impl.dart] - Moved file: $sourcePath -> $destinationPath',
        );
      }
    } catch (e) {
      developer.log('[storage_repository_impl.dart] - Error moving file: $e');
      throw Exception('Failed to move file: $e');
    }
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
      developer.log(
        '[storage_repository_impl.dart] - Error getting file size: $e',
      );
      return 0;
    }
  }

  @override
  Future<List<String>> getFilesInDirectory(String directoryPath) async {
    try {
      final dir = Directory(directoryPath);
      if (await dir.exists()) {
        final files = await dir
            .list()
            .where((entity) => entity is File)
            .toList();
        return files.map((file) => file.path).toList();
      }
      return [];
    } catch (e) {
      developer.log(
        '[storage_repository_impl.dart] - Error getting files in directory: $e',
      );
      return [];
    }
  }
}
