/// Utility functions for file operations
class FileUtils {
  /// Format file size from bytes to human readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Format file size with custom precision
  static String formatFileSizeWithPrecision(int bytes, {int precision = 1}) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(precision)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(precision)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(precision)} GB';
  }

  /// Get file extension from path
  static String getFileExtension(String path) {
    final parts = path.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return '';
  }

  /// Get file name without extension
  static String getFileNameWithoutExtension(String path) {
    final fileName = path.split('/').last;
    final parts = fileName.split('.');
    if (parts.length > 1) {
      return parts.take(parts.length - 1).join('.');
    }
    return fileName;
  }

  /// Check if file is video format
  static bool isVideoFile(String path) {
    final extension = getFileExtension(path);
    return [
      'mp4',
      'avi',
      'mkv',
      'mov',
      'wmv',
      'flv',
      'webm',
    ].contains(extension);
  }

  /// Check if file is audio format
  static bool isAudioFile(String path) {
    final extension = getFileExtension(path);
    return ['mp3', 'aac', 'ogg', 'wav', 'flac', 'm4a'].contains(extension);
  }

  /// Format datetime to time string (HH:mm)
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'N/A';
    }
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Format datetime to date string (dd/MM/yyyy)
  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return 'N/A';
    }
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  /// Format datetime to full string (dd/MM/yyyy HH:mm)
  static String formatDateTimeFull(DateTime? dateTime) {
    if (dateTime == null) {
      return 'N/A';
    }
    return '${formatDate(dateTime)} ${formatDateTime(dateTime)}';
  }
}
