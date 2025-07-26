/// Utility class for VideoInfo operations
class VideoInfoUtils {
  /// Validates if the provided URL is a valid YouTube video URL
  static bool isValidVideoUrl(String url) {
    final youtubeVideoPattern = RegExp(
      r'^(https?://)?(www\.)?(youtube\.com/watch\?v=|youtu\.be/|youtube\.com/embed/)[a-zA-Z0-9_-]{11}.*$',
      caseSensitive: false,
    );
    return youtubeVideoPattern.hasMatch(url);
  }

  /// Validates if a URL is a valid YouTube playlist URL
  static bool isValidPlaylistUrl(String url) {
    final playlistPattern = RegExp(
      r'^(https?://)?(www\.)?(youtube\.com/playlist\?list=|youtube\.com/watch\?.*&list=)[a-zA-Z0-9_-]+.*$',
      caseSensitive: false,
    );
    return playlistPattern.hasMatch(url);
  }

  /// Extracts video ID from YouTube URL
  static String? extractVideoId(String url) {
    final patterns = [
      RegExp(
        r'(?:youtube\.com/watch\?v=|youtu\.be/|youtube\.com/embed/)([a-zA-Z0-9_-]{11})',
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }

  /// Extracts playlist ID from YouTube URL
  static String? extractPlaylistId(String url) {
    final patterns = [
      RegExp(
        r'(?:youtube\.com/playlist\?list=|youtube\.com/watch\?.*&list=)([a-zA-Z0-9_-]+)',
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }
}
