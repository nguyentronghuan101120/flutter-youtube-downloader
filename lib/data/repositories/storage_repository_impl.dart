import 'package:injectable/injectable.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;
import '../../domain/repositories/storage_repository.dart';
import 'package:flutter/foundation.dart';

@Injectable(as: StorageRepository)
class StorageRepositoryImpl implements StorageRepository {
  @override
  Future<String> getDefaultDownloadPath() async {
    try {
      if (kIsWeb) {
        // Web platform - use temporary directory
        final tempDir = await getTemporaryDirectory();
        final downloadsDir = Directory('${tempDir.path}/downloads');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        developer.log(
          '[storage_repository_impl.dart] - Using web downloads: ${downloadsDir.path}',
        );
        return downloadsDir.path;
      }

      if (Platform.isAndroid) {
        // Android platform
        try {
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            // Try to get the system Downloads directory directly
            final downloadsDir = Directory('/storage/emulated/0/Download');

            if (!await downloadsDir.exists()) {
              await downloadsDir.create(recursive: true);
            }

            developer.log(
              '[storage_repository_impl.dart] - Using Android system downloads: ${downloadsDir.path}',
            );
            return downloadsDir.path;
          }
        } catch (e) {
          developer.log(
            '[storage_repository_impl.dart] - Android external storage failed, using fallback: $e',
          );
        }
      } else if (Platform.isIOS) {
        // iOS platform - use app documents directory
        final documentsDir = await getApplicationDocumentsDirectory();
        final downloadsDir = Directory('${documentsDir.path}/downloads');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        developer.log(
          '[storage_repository_impl.dart] - Using iOS downloads: ${downloadsDir.path}',
        );
        return downloadsDir.path;
      } else if (Platform.isMacOS) {
        // macOS platform - use app documents directory due to sandbox restrictions
        // Users can manually move files to Downloads folder if needed
        final documentsDir = await getApplicationDocumentsDirectory();
        final downloadsDir = Directory('${documentsDir.path}/Downloads');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        developer.log(
          '[storage_repository_impl.dart] - Using macOS app documents downloads: ${downloadsDir.path}',
        );
        return downloadsDir.path;
      } else if (Platform.isWindows) {
        // Windows platform - use user's Downloads folder
        final homePath = Platform.environment['USERPROFILE'];
        if (homePath != null) {
          final downloadsDir = Directory('$homePath/Downloads');

          if (await downloadsDir.exists()) {
            // Create a subdirectory for the app
            final appDownloadsDir = Directory(
              '${downloadsDir.path}/YouTubeDownloader',
            );
            if (!await appDownloadsDir.exists()) {
              await appDownloadsDir.create(recursive: true);
            }
            developer.log(
              '[storage_repository_impl.dart] - Using Windows Downloads: ${appDownloadsDir.path}',
            );
            return appDownloadsDir.path;
          }
        }

        // Fallback to app documents directory
        final documentsDir = await getApplicationDocumentsDirectory();
        final downloadsDir = Directory('${documentsDir.path}/downloads');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        developer.log(
          '[storage_repository_impl.dart] - Using Windows app documents downloads: ${downloadsDir.path}',
        );
        return downloadsDir.path;
      } else if (Platform.isLinux) {
        // Linux platform - use user's Downloads folder
        final homePath = Platform.environment['HOME'];
        if (homePath != null) {
          final downloadsDir = Directory('$homePath/Downloads');

          if (await downloadsDir.exists()) {
            // Create a subdirectory for the app
            final appDownloadsDir = Directory(
              '${downloadsDir.path}/YouTubeDownloader',
            );
            if (!await appDownloadsDir.exists()) {
              await appDownloadsDir.create(recursive: true);
            }
            developer.log(
              '[storage_repository_impl.dart] - Using Linux Downloads: ${appDownloadsDir.path}',
            );
            return appDownloadsDir.path;
          }
        }

        // Fallback to app documents directory
        final documentsDir = await getApplicationDocumentsDirectory();
        final downloadsDir = Directory('${documentsDir.path}/downloads');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        developer.log(
          '[storage_repository_impl.dart] - Using Linux app documents downloads: ${downloadsDir.path}',
        );
        return downloadsDir.path;
      }

      // Fallback to app documents directory for any other platform
      final documentsDir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${documentsDir.path}/downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      developer.log(
        '[storage_repository_impl.dart] - Using fallback downloads: ${downloadsDir.path}',
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
      if (Platform.isAndroid) {
        // For Android 10+ (API 29+), we don't need explicit permission for app-specific storage
        // For older versions, we'll assume permission is granted if we can access external storage
        final externalDir = await getExternalStorageDirectory();
        return externalDir != null;
      } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        // Desktop platforms don't require explicit storage permissions
        return true;
      } else if (Platform.isIOS) {
        // iOS uses app sandbox, so we have permission to app documents
        return true;
      }
      return false;
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
      if (Platform.isAndroid) {
        // For now, we'll assume permission is granted if we can access external storage
        // In a real app, you would use permission_handler package to request permissions
        final externalDir = await getExternalStorageDirectory();
        return externalDir != null;
      } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        // Desktop platforms don't require explicit storage permissions
        return true;
      } else if (Platform.isIOS) {
        // iOS uses app sandbox, so we have permission to app documents
        return true;
      }
      return false;
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

  @override
  Future<String?> getSystemDownloadsPath() async {
    try {
      if (Platform.isMacOS) {
        final homePath = Platform.environment['HOME'];
        if (homePath != null) {
          final downloadsDir = Directory('$homePath/Downloads');
          if (await downloadsDir.exists()) {
            return downloadsDir.path;
          }
        }
      } else if (Platform.isWindows) {
        final homePath = Platform.environment['USERPROFILE'];
        if (homePath != null) {
          final downloadsDir = Directory('$homePath/Downloads');
          if (await downloadsDir.exists()) {
            return downloadsDir.path;
          }
        }
      } else if (Platform.isLinux) {
        final homePath = Platform.environment['HOME'];
        if (homePath != null) {
          final downloadsDir = Directory('$homePath/Downloads');
          if (await downloadsDir.exists()) {
            return downloadsDir.path;
          }
        }
      }
      return null;
    } catch (e) {
      developer.log(
        '[storage_repository_impl.dart] - Error getting system downloads path: $e',
      );
      return null;
    }
  }

  /// Move downloaded file to system Downloads folder (macOS only)
  /// Returns the new path if successful, null if failed
  @override
  Future<String?> moveToSystemDownloads(String filePath) async {
    try {
      if (!Platform.isMacOS) {
        developer.log(
          '[storage_repository_impl.dart] - moveToSystemDownloads: Only supported on macOS',
        );
        return null;
      }

      final sourceFile = File(filePath);
      if (!await sourceFile.exists()) {
        developer.log(
          '[storage_repository_impl.dart] - moveToSystemDownloads: Source file does not exist: $filePath',
        );
        return null;
      }

      final systemDownloadsPath = await getSystemDownloadsPath();
      if (systemDownloadsPath == null) {
        developer.log(
          '[storage_repository_impl.dart] - moveToSystemDownloads: Could not get system downloads path',
        );
        return null;
      }

      final fileName = sourceFile.uri.pathSegments.last;
      final destinationPath = '$systemDownloadsPath/$fileName';

      // Check if file already exists in destination
      final destFile = File(destinationPath);
      if (await destFile.exists()) {
        // Add timestamp to avoid conflicts
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final nameWithoutExt = fileName.substring(0, fileName.lastIndexOf('.'));
        final extension = fileName.substring(fileName.lastIndexOf('.'));
        final newFileName = '${nameWithoutExt}_$timestamp$extension';
        final newDestinationPath = '$systemDownloadsPath/$newFileName';

        await sourceFile.copy(newDestinationPath);
        await sourceFile.delete();

        developer.log(
          '[storage_repository_impl.dart] - moveToSystemDownloads: File moved with timestamp: $newDestinationPath',
        );
        return newDestinationPath;
      } else {
        // Move file directly
        await sourceFile.rename(destinationPath);

        developer.log(
          '[storage_repository_impl.dart] - moveToSystemDownloads: File moved successfully: $destinationPath',
        );
        return destinationPath;
      }
    } catch (e) {
      developer.log(
        '[storage_repository_impl.dart] - moveToSystemDownloads: Error moving file: $e',
      );
      return null;
    }
  }

  /// Check if file is in system Downloads folder
  @override
  bool isInSystemDownloads(String filePath) {
    try {
      if (Platform.isMacOS) {
        final homePath = Platform.environment['HOME'];
        if (homePath != null) {
          final downloadsDir = '$homePath/Downloads';
          return filePath.startsWith(downloadsDir);
        }
      } else if (Platform.isWindows) {
        final homePath = Platform.environment['USERPROFILE'];
        if (homePath != null) {
          final downloadsDir = '$homePath/Downloads';
          return filePath.startsWith(downloadsDir);
        }
      } else if (Platform.isLinux) {
        final homePath = Platform.environment['HOME'];
        if (homePath != null) {
          final downloadsDir = '$homePath/Downloads';
          return filePath.startsWith(downloadsDir);
        }
      }
      return false;
    } catch (e) {
      developer.log(
        '[storage_repository_impl.dart] - isInSystemDownloads: Error checking path: $e',
      );
      return false;
    }
  }
}
