/// Application constants for YouTube Downloader
class AppConstants {
  // App Information
  static const String appName = 'YouTube Downloader';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Download YouTube videos and audio with ease';

  // API Configuration
  static const String youtubeApiBaseUrl = 'https://www.youtube.com';
  static const String youtubeWatchUrl = 'https://www.youtube.com/watch';
  static const String youtubeEmbedUrl = 'https://www.youtube.com/embed';

  // Request Configuration
  static const Duration requestTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Download Configuration
  static const String defaultDownloadPath = '/Downloads/YouTube';
  static const int maxConcurrentDownloads = 3;
  static const Duration downloadTimeout = Duration(minutes: 10);

  // Video Quality Presets
  static const Map<String, int> videoQualityPresets = {
    '4K': 2160,
    '2K': 1440,
    '1080p': 1080,
    '720p': 720,
    '480p': 480,
    '360p': 360,
    '240p': 240,
    '144p': 144,
  };

  // Audio Quality Presets
  static const Map<String, int> audioQualityPresets = {
    'High Quality': 320000,
    'Very Good': 256000,
    'Good': 192000,
    'Standard': 128000,
    'Low': 96000,
    'Very Low': 64000,
  };

  // Supported Video Formats
  static const List<String> supportedVideoFormats = [
    'mp4',
    'webm',
    '3gp',
    'flv',
  ];

  // Supported Audio Formats
  static const List<String> supportedAudioFormats = [
    'mp3',
    'aac',
    'ogg',
    'opus',
    'wav',
    'flac',
  ];

  // Video Codecs
  static const List<String> supportedVideoCodecs = [
    'H.264',
    'H.265',
    'VP9',
    'VP8',
    'H.263',
  ];

  // Audio Codecs
  static const List<String> supportedAudioCodecs = [
    'AAC',
    'MP3',
    'Opus',
    'Vorbis',
    'FLAC',
  ];

  // Quality Labels
  static const Map<String, String> qualityLabels = {
    'tiny': '144p',
    'small': '240p',
    'medium': '360p',
    'large': '480p',
    'hd720': '720p',
    'hd1080': '1080p',
    'hd1440': '2K',
    'hd2160': '4K',
  };

  // File Size Units
  static const List<String> fileSizeUnits = ['B', 'KB', 'MB', 'GB', 'TB'];

  // Download States
  static const String downloadStateQueued = 'queued';
  static const String downloadStateDownloading = 'downloading';
  static const String downloadStatePaused = 'paused';
  static const String downloadStateCompleted = 'completed';
  static const String downloadStateFailed = 'failed';
  static const String downloadStateCancelled = 'cancelled';

  // Error Messages
  static const String errorInvalidUrl = 'Invalid YouTube URL';
  static const String errorVideoNotFound = 'Video not found or unavailable';
  static const String errorNetworkError = 'Network error occurred';
  static const String errorDownloadFailed = 'Download failed';
  static const String errorNoStreamsAvailable =
      'No streams available for download';
  static const String errorStoragePermission = 'Storage permission required';

  // Success Messages
  static const String successVideoAnalyzed = 'Video analyzed successfully';
  static const String successDownloadStarted = 'Download started';
  static const String successDownloadCompleted = 'Download completed';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 48.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB

  // Validation Patterns
  static const String youtubeUrlPattern =
      r'^(https?://)?(www\.)?(youtube\.com|youtu\.be)/.+$';
  static const String videoIdPattern =
      r'(?:youtube\.com/watch\?v=|youtu\.be/)([a-zA-Z0-9_-]{11})';

  // Default Preferences
  static const String defaultVideoQuality = '720p';
  static const String defaultAudioQuality = '128000';
  static const String defaultVideoFormat = 'mp4';
  static const String defaultAudioFormat = 'mp3';
  static const bool defaultAutoDownload = false;
  static const bool defaultShowNotifications = true;

  // Notification IDs
  static const int downloadNotificationId = 1001;
  static const int errorNotificationId = 1002;
  static const int successNotificationId = 1003;

  // Channel Names
  static const String downloadChannelName = 'download_channel';
  static const String downloadChannelDescription =
      'Download progress notifications';

  // Shared Preferences Keys
  static const String prefVideoQuality = 'video_quality';
  static const String prefAudioQuality = 'audio_quality';
  static const String prefVideoFormat = 'video_format';
  static const String prefAudioFormat = 'audio_format';
  static const String prefDownloadPath = 'download_path';
  static const String prefAutoDownload = 'auto_download';
  static const String prefShowNotifications = 'show_notifications';
  static const String prefMaxConcurrentDownloads = 'max_concurrent_downloads';
}

enum DownloadType { audioOnly, videoOnly }
