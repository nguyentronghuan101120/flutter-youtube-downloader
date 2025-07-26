import 'dart:io';

class AppConstants {
  static const String appName = 'YouTube Downloader';
  static const String appVersion = '1.0.0';
  static const String packageId = 'com.flutteryoutubedownloader.app';

  // API Constants
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 60000; // 60 seconds

  // Dynamic concurrent downloads based on CPU cores
  static int get maxConcurrentDownloads {
    try {
      return Platform.numberOfProcessors;
    } catch (e) {
      return 4; // Fallback to 4 if cannot detect CPU cores
    }
  }

  // Chunked download constants
  static const int chunkSize = 1024 * 1024; // 1MB per chunk
  static const int maxChunkConcurrency = 4; // Max chunks per download
  static const int progressUpdateInterval = 500; // 500ms instead of 100ms

  // File Constants
  static const String defaultDownloadFolder = 'Downloads';
  static const String tempFolder = 'temp';
  static const int maxRetryAttempts = 3;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double defaultIconSize = 24.0;

  // Supported Video Formats
  static const List<String> supportedVideoFormats = ['mp4', 'webm'];
  static const List<String> supportedAudioFormats = [
    'mp3',
    'm4a',
    'wav',
    'flac',
  ];

  // Quality Options
  static const List<String> videoQualities = [
    '144p',
    '240p',
    '360p',
    '480p',
    '720p',
    '1080p',
    '1440p',
    '2160p',
    '4320p',
  ];

  static const List<String> audioBitrates = [
    '48kbps',
    '64kbps',
    '96kbps',
    '128kbps',
    '160kbps',
    '192kbps',
    '256kbps',
    '320kbps',
  ];
}

enum DownloadType { audioOnly, videoOnly }
