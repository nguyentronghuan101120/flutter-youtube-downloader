import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/video_info.dart';

class VideoInfoWidget extends StatelessWidget {
  final VideoInfo videoInfo;
  final DownloadType downloadType;
  final String selectedFormat;
  final String selectedQuality;
  final VoidCallback? onRetry;
  final bool isLoading;

  const VideoInfoWidget({
    super.key,
    required this.videoInfo,
    required this.downloadType,
    required this.selectedFormat,
    required this.selectedQuality,
    this.onRetry,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Analyzing video...'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail và thông tin cơ bản
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail với error handling
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      videoInfo.thumbnailUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[300],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.video_library,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Thumbnail unavailable',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title với better overflow handling
                  Text(
                    videoInfo.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Channel name với link style
                  Row(
                    children: [
                      Icon(
                        Icons.account_circle,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          videoInfo.channelName,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Enhanced metadata row
                  _buildMetadataRow(context),

                  // Upload date if available
                  if (videoInfo.uploadDate != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Uploaded: ${_formatUploadDate(videoInfo.uploadDate!)}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],

                  // Like count if available
                  if (videoInfo.likeCount != null &&
                      videoInfo.likeCount! > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.thumb_up, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _formatLikeCount(videoInfo.likeCount!),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Video streams - chỉ hiển thị khi chọn Video Only và có stream phù hợp
          if (downloadType == DownloadType.videoOnly) ...[
            _buildVideoStreamsSection(context),
          ],

          // Audio streams - chỉ hiển thị khi chọn Audio Only và có stream phù hợp
          if (downloadType == DownloadType.audioOnly) ...[
            _buildAudioStreamsSection(context),
          ],

          // Thông báo khi không có stream phù hợp
          if (_getMatchingStreams().isEmpty) ...[
            _buildNoStreamsWarning(context),
          ],

          // Retry button if onRetry is provided
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Analysis'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadataRow(BuildContext context) {
    return Row(
      children: [
        // Duration
        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          _formatDuration(videoInfo.duration),
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),

        // View count
        Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          _formatViewCount(videoInfo.viewCount),
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNoStreamsWarning(BuildContext context) {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange[700],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    downloadType == DownloadType.audioOnly
                        ? 'No ${selectedFormat.toLowerCase()} audio streams available'
                        : 'No ${selectedFormat.toLowerCase()} video streams available with $selectedQuality quality',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Available alternatives:',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _buildAvailableAlternatives(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoStreamsSection(BuildContext context) {
    final matchingStreams = _getMatchingStreams();

    if (matchingStreams.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Video Formats',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ...matchingStreams.map(
          (stream) => _buildStreamCard(
            context,
            stream.quality,
            stream.format,
            stream.fileSize,
            stream.bitrate,
            Icons.video_file,
          ),
        ),
      ],
    );
  }

  Widget _buildAudioStreamsSection(BuildContext context) {
    final matchingStreams = _getMatchingStreams();

    if (matchingStreams.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Audio Formats',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ...matchingStreams.map(
          (stream) => _buildStreamCard(
            context,
            '${stream.bitrate ~/ 1000}kbps',
            stream.format,
            stream.fileSize,
            stream.bitrate,
            Icons.audiotrack,
          ),
        ),
      ],
    );
  }

  List<dynamic> _getMatchingStreams() {
    if (downloadType == DownloadType.audioOnly) {
      debugPrint('Audio Only selected, format: $selectedFormat');
      debugPrint(
        'Available audio streams: ${videoInfo.audioStreams.map((s) => s.format).toList()}',
      );

      return videoInfo.audioStreams.where((stream) {
        final matches =
            selectedFormat.toUpperCase() == stream.format.toUpperCase();
        debugPrint(
          'Checking ${stream.format} against $selectedFormat: $matches',
        );
        return matches;
      }).toList();
    } else {
      debugPrint(
        'Video Only selected, format: $selectedFormat, quality: $selectedQuality',
      );
      debugPrint(
        'Available video streams: ${videoInfo.videoStreams.map((s) => '${s.format}(${s.quality})').toList()}',
      );

      return videoInfo.videoStreams.where((stream) {
        // Kiểm tra format
        if (selectedFormat.toUpperCase() != stream.format.toUpperCase()) {
          return false;
        }
        // Kiểm tra quality
        if (selectedQuality.isNotEmpty && stream.quality != selectedQuality) {
          return false;
        }
        return true;
      }).toList();
    }
  }

  Widget _buildAvailableAlternatives(BuildContext context) {
    if (downloadType == DownloadType.audioOnly) {
      if (videoInfo.audioStreams.isEmpty) {
        return Text(
          'No audio streams available for this video',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        );
      }

      final audioStreams = videoInfo.audioStreams.cast<AudioStream>();
      final formats = audioStreams.map((s) => s.format.toUpperCase()).toSet();
      final availableOptions = formats.map((f) => 'Audio: $f').toList();

      return Wrap(
        spacing: 8,
        runSpacing: 4,
        children: availableOptions
            .take(6)
            .map(
              (option) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
            .toList(),
      );
    } else {
      if (videoInfo.videoStreams.isEmpty) {
        return Text(
          'No video streams available for this video',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        );
      }

      final videoStreams = videoInfo.videoStreams.cast<VideoStream>();
      final formatQualityPairs = videoStreams
          .map((s) => '${s.format.toUpperCase()} (${s.quality})')
          .toSet();
      final availableOptions = formatQualityPairs.toList();

      return Wrap(
        spacing: 8,
        runSpacing: 4,
        children: availableOptions
            .take(6)
            .map(
              (option) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
            .toList(),
      );
    }
  }

  Widget _buildStreamCard(
    BuildContext context,
    String quality,
    String format,
    int fileSize,
    int bitrate,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text('$quality ($format)'),
        subtitle: Text('${_formatFileSize(fileSize)} • ${bitrate ~/ 1000}kbps'),
        trailing: ElevatedButton(
          onPressed: () {
            // TODO: Implement download functionality with selected format and quality
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Downloading in $format ${quality.isNotEmpty ? '($quality)' : ''} format...',
                ),
              ),
            );
          },
          child: const Text('Download'),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }

  String _formatViewCount(int? viewCount) {
    if (viewCount == null) return 'Unknown views';

    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M views';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K views';
    } else {
      return '$viewCount views';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes >= 1073741824) {
      return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
    } else if (bytes >= 1048576) {
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '$bytes B';
    }
  }

  String _formatUploadDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }

  String _formatLikeCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M likes';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K likes';
    } else {
      return '$count likes';
    }
  }
}
