import 'dart:io';
import 'dart:developer' as developer;

class DownloadFileService {
  /// Move file to system Downloads folder if on macOS and not already there
  Future<String?> moveToSystemDownloadsIfNeeded(String filePath) async {
    try {
      if (!Platform.isMacOS) {
        return null; // Only for macOS
      }

      // Check if file is already in system Downloads
      if (_isInSystemDownloads(filePath)) {
        developer.log(
          '[download_file_service.dart] - File already in system Downloads: $filePath',
        );
        return filePath;
      }

      // Try to move file to system Downloads
      final newPath = await moveToSystemDownloads(filePath);
      if (newPath != null) {
        developer.log(
          '[download_file_service.dart] - File moved to system Downloads: $newPath',
        );
      } else {
        developer.log(
          '[download_file_service.dart] - Failed to move file to system Downloads: $filePath',
        );
      }
      return newPath;
    } catch (e) {
      developer.log(
        '[download_file_service.dart] - Error moving file to system Downloads: $e',
      );
      return null;
    }
  }

  /// Move downloaded file to system Downloads folder (macOS only)
  /// Returns the new path if successful, null if failed
  Future<String?> moveToSystemDownloads(String filePath) async {
    try {
      if (!Platform.isMacOS) {
        developer.log(
          '[download_file_service.dart] - moveToSystemDownloads: Only supported on macOS',
        );
        return null;
      }

      final sourceFile = File(filePath);
      if (!await sourceFile.exists()) {
        developer.log(
          '[download_file_service.dart] - moveToSystemDownloads: Source file does not exist: $filePath',
        );
        return null;
      }

      final systemDownloadsPath = await _getSystemDownloadsPath();
      if (systemDownloadsPath == null) {
        developer.log(
          '[download_file_service.dart] - moveToSystemDownloads: Could not get system downloads path',
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
          '[download_file_service.dart] - moveToSystemDownloads: File moved with timestamp: $newDestinationPath',
        );
        return newDestinationPath;
      } else {
        // Move file directly
        await sourceFile.rename(destinationPath);

        developer.log(
          '[download_file_service.dart] - moveToSystemDownloads: File moved successfully: $destinationPath',
        );
        return destinationPath;
      }
    } catch (e) {
      developer.log(
        '[download_file_service.dart] - moveToSystemDownloads: Error moving file: $e',
      );
      return null;
    }
  }

  /// Get system Downloads path
  Future<String?> _getSystemDownloadsPath() async {
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
        '[download_file_service.dart] - _getSystemDownloadsPath: Error getting system downloads path: $e',
      );
      return null;
    }
  }

  /// Check if file is in system Downloads folder
  bool _isInSystemDownloads(String filePath) {
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
        '[download_file_service.dart] - _isInSystemDownloads: Error checking path: $e',
      );
      return false;
    }
  }

  /// Check if file is in system Downloads folder (public method)
  bool isInSystemDownloads(String filePath) {
    return _isInSystemDownloads(filePath);
  }

  /// Open file using system default application
  Future<bool> openFile(String filePath) async {
    try {
      developer.log('[download_file_service.dart] - Opening file: $filePath');
      // TODO: Implement file opening functionality using url_launcher
      // For now, just return true as placeholder
      return true;
    } catch (e) {
      developer.log('[download_file_service.dart] - Error opening file: $e');
      return false;
    }
  }

  /// Cleanup failed download file
  Future<void> cleanupFailedDownload(String outputPath) async {
    if (outputPath.isNotEmpty) {
      final file = File(outputPath);
      if (await file.exists()) {
        await file.delete();
        developer.log(
          '[download_file_service.dart] - Cleaned up partial file: $outputPath',
        );
      }
    }
  }
}
