import 'package:flutter/material.dart';
import '../../domain/entities/video_info.dart';

class VideoInfoWidget extends StatelessWidget {
  final VideoInfo videoInfo;

  const VideoInfoWidget({super.key, required this.videoInfo});

  @override
  Widget build(BuildContext context) {
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
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      videoInfo.thumbnailUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.video_library,
                            size: 64,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    videoInfo.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Channel name
                  Text(
                    videoInfo.channelName,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),

                  // Duration và view count
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(videoInfo.duration),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        _formatViewCount(videoInfo.viewCount),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Video streams
          if (videoInfo.videoStreams.isNotEmpty) ...[
            Text(
              'Video Formats',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...videoInfo.videoStreams.map(
              (stream) => _buildStreamCard(
                context,
                stream.quality,
                stream.format,
                stream.fileSize,
                stream.bitrate,
                Icons.video_file,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Audio streams
          if (videoInfo.audioStreams.isNotEmpty) ...[
            Text(
              'Audio Formats',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...videoInfo.audioStreams.map(
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
        ],
      ),
    );
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
            // TODO: Implement download functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Download functionality coming soon!'),
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
}
