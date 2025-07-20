import 'package:flutter/material.dart';
import '../../domain/entities/video_stream.dart';
import '../../domain/entities/audio_stream.dart';
import '../../core/constants/app_constants.dart';

/// Widget for comparing quality and file size between different formats
class QualityComparisonWidget extends StatelessWidget {
  final List<VideoStream> videoStreams;
  final List<AudioStream> audioStreams;
  final int? videoDuration;
  final VideoStream? selectedVideoStream;
  final AudioStream? selectedAudioStream;

  const QualityComparisonWidget({
    super.key,
    required this.videoStreams,
    required this.audioStreams,
    this.videoDuration,
    this.selectedVideoStream,
    this.selectedAudioStream,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Quality Comparison', Icons.compare),
        const SizedBox(height: AppConstants.defaultPadding),
        if (videoStreams.isNotEmpty) ...[
          _buildVideoComparison(context),
          const SizedBox(height: AppConstants.defaultPadding),
        ],
        if (audioStreams.isNotEmpty) ...[_buildAudioComparison(context)],
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: AppConstants.smallPadding),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoComparison(BuildContext context) {
    // Sort streams by quality (height) in descending order
    final sortedStreams = List<VideoStream>.from(videoStreams)
      ..sort((a, b) => b.height.compareTo(a.height));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Video Quality Comparison',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        _buildComparisonTable(context, sortedStreams, isVideo: true),
      ],
    );
  }

  Widget _buildAudioComparison(BuildContext context) {
    // Sort streams by bitrate in descending order
    final sortedStreams = List<AudioStream>.from(audioStreams)
      ..sort((a, b) => b.bitrate.compareTo(a.bitrate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Audio Quality Comparison',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        _buildComparisonTable(context, sortedStreams, isVideo: false),
      ],
    );
  }

  Widget _buildComparisonTable(
    BuildContext context,
    List<dynamic> streams, {
    required bool isVideo,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.borderRadius),
                topRight: Radius.circular(AppConstants.borderRadius),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Quality',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Format',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Bitrate',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Size',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 40), // Space for selection indicator
              ],
            ),
          ),
          // Rows
          ...streams.map(
            (stream) => _buildComparisonRow(context, stream, isVideo: isVideo),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    BuildContext context,
    dynamic stream, {
    required bool isVideo,
  }) {
    final isSelected = isVideo
        ? selectedVideoStream?.id == stream.id
        : selectedAudioStream?.id == stream.id;

    final theme = Theme.of(context);
    final rowColor = isSelected ? theme.primaryColor.withOpacity(0.05) : null;

    return Container(
      color: rowColor,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildQualityBadge(
                        isVideo ? stream.qualityLevel : stream.qualityLevel,
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      Text(
                        isVideo ? stream.displayResolution : stream.displayName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (isVideo && stream.fps != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${stream.fps} FPS',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ],
                  if (!isVideo) ...[
                    const SizedBox(height: 2),
                    Text(
                      stream.channelConfig,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Text(
                stream.format.toUpperCase(),
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Text(
                stream.formattedBitrate,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Text(
                videoDuration != null
                    ? stream.getFormattedFileSize(videoDuration!)
                    : 'N/A',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: isSelected
                ? Icon(Icons.check_circle, color: theme.primaryColor, size: 20)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildQualityBadge(String quality) {
    Color badgeColor;
    Color textColor = Colors.white;

    switch (quality.toLowerCase()) {
      case '4k':
      case 'high quality':
        badgeColor = Colors.red;
        break;
      case '2k':
      case 'very good':
        badgeColor = Colors.orange;
        break;
      case '1080p':
      case 'good':
        badgeColor = Colors.green;
        break;
      case '720p':
      case 'standard':
        badgeColor = Colors.blue;
        break;
      case '480p':
      case 'low':
        badgeColor = Colors.yellow;
        textColor = Colors.black;
        break;
      default:
        badgeColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        quality,
        style: TextStyle(
          color: textColor,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
