import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../domain/repositories/storage_repository.dart';

class FileManager {
  final StorageRepository _storageRepository;

  FileManager({required StorageRepository storageRepository})
    : _storageRepository = storageRepository;

  /// Gets the download directory
  Future<String?> getDownloadDirectory() async {
    final result = await _storageRepository.getDownloadDirectory();
    return result.fold((failure) => null, (path) => path);
  }

  /// Creates a safe filename
  String generateSafeFileName(String originalName, String extension) {
    final safeName = originalName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_');
    return '${safeName}_${DateTime.now().millisecondsSinceEpoch}.$extension';
  }

  /// Gets file extension from format ID
  String getFileExtension(String formatId) {
    if (formatId.contains('mp4')) return 'mp4';
    if (formatId.contains('webm')) return 'webm';
    if (formatId.contains('mp3')) return 'mp3';
    if (formatId.contains('aac')) return 'aac';
    if (formatId.contains('ogg')) return 'ogg';
    return 'mp4'; // default
  }

  /// Creates a complete file path for download
  Future<String?> createDownloadPath(String title, String formatId) async {
    final downloadDir = await getDownloadDirectory();
    if (downloadDir == null) return null;

    final extension = getFileExtension(formatId);
    final fileName = generateSafeFileName(title, extension);
    return '$downloadDir/$fileName';
  }

  /// Checks if there's enough storage space
  Future<bool> hasEnoughSpace(int requiredBytes) async {
    final availableSpace = await _storageRepository.getAvailableStorageSpace();
    return availableSpace.fold(
      (failure) => false,
      (space) => space >= requiredBytes,
    );
  }

  /// Gets file size in human readable format
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Gets download speed in human readable format
  String formatDownloadSpeed(double bytesPerSecond) {
    if (bytesPerSecond < 1024)
      return '${bytesPerSecond.toStringAsFixed(1)} B/s';
    if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    }
    return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }

  /// Formats time duration
  String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    }
    return '${duration.inSeconds}s';
  }

  /// Organizes downloaded files by type
  Future<bool> organizeDownloadedFiles() async {
    final result = await _storageRepository.organizeFiles();
    return result.fold((failure) => false, (success) => success);
  }

  /// Cleans up temporary files
  Future<bool> cleanupTempFiles() async {
    final result = await _storageRepository.cleanupTempFiles();
    return result.fold((failure) => false, (success) => success);
  }

  /// Deletes a file
  Future<bool> deleteFile(String filePath) async {
    final result = await _storageRepository.deleteFile(filePath);
    return result.fold((failure) => false, (success) => success);
  }

  /// Gets file information
  Future<FileInfo?> getFileInfo(String filePath) async {
    final result = await _storageRepository.getFileInfo(filePath);
    return result.fold((failure) => null, (info) => info);
  }

  /// Lists all files in download directory
  Future<List<String>> listDownloadedFiles() async {
    final downloadDir = await getDownloadDirectory();
    if (downloadDir == null) return [];

    final result = await _storageRepository.listFiles(downloadDir);
    return result.fold((failure) => [], (files) => files);
  }

  /// Gets total size of downloaded files
  Future<int> getTotalDownloadedSize() async {
    final files = await listDownloadedFiles();
    int totalSize = 0;

    for (final filePath in files) {
      final fileInfo = await getFileInfo(filePath);
      if (fileInfo != null) {
        totalSize += fileInfo.size;
      }
    }

    return totalSize;
  }

  /// Gets file category based on extension
  String getFileCategory(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'mp4':
      case 'webm':
      case 'avi':
      case 'mkv':
        return 'Videos';
      case 'mp3':
      case 'aac':
      case 'ogg':
      case 'wav':
        return 'Audio';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return 'Images';
      case 'pdf':
      case 'doc':
      case 'docx':
      case 'txt':
        return 'Documents';
      default:
        return 'Others';
    }
  }

  /// Validates file path
  bool isValidFilePath(String filePath) {
    try {
      final file = File(filePath);
      return file.path.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Creates a backup of a file
  Future<String?> createBackup(String filePath) async {
    if (!isValidFilePath(filePath)) return null;

    final fileInfo = await getFileInfo(filePath);
    if (fileInfo == null) return null;

    final backupName =
        '${fileInfo.name}_backup_${DateTime.now().millisecondsSinceEpoch}';
    final backupPath =
        '${filePath.substring(0, filePath.lastIndexOf('/'))}/$backupName';

    final result = await _storageRepository.copyFile(filePath, backupPath);
    return result.fold((failure) => null, (path) => path);
  }

  /// Gets storage usage statistics
  Future<StorageStats> getStorageStats() async {
    final totalSpace = await _storageRepository.getTotalStorageSpace();
    final availableSpace = await _storageRepository.getAvailableStorageSpace();
    final downloadedSize = await getTotalDownloadedSize();

    return StorageStats(
      totalSpace: totalSpace.fold((failure) => 0, (space) => space),
      availableSpace: availableSpace.fold((failure) => 0, (space) => space),
      usedSpace: downloadedSize,
    );
  }
}

/// Storage statistics data class
class StorageStats {
  final int totalSpace;
  final int availableSpace;
  final int usedSpace;

  StorageStats({
    required this.totalSpace,
    required this.availableSpace,
    required this.usedSpace,
  });

  double get usagePercentage {
    if (totalSpace == 0) return 0.0;
    return (usedSpace / totalSpace) * 100;
  }

  int get freeSpace => totalSpace - usedSpace;
}
