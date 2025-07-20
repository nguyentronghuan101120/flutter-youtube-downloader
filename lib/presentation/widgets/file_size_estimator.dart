import 'package:flutter/material.dart';
import '../../domain/entities/video_stream.dart';
import '../../domain/entities/audio_stream.dart';
import '../../core/constants/app_constants.dart';

/// Widget for estimating file size based on video/audio streams and duration
class FileSizeEstimator extends StatelessWidget {
  final VideoStream? videoStream;
  final AudioStream? audioStream;
  final int? durationSeconds;
  final bool showDetails;

  const FileSizeEstimator({
    super.key,
    this.videoStream,
    this.audioStream,
    this.durationSeconds,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    if (videoStream == null && audioStream == null) {
      return const SizedBox.shrink();
    }

    final totalSize = _calculateTotalSize();
    final formattedSize = _formatFileSize(totalSize);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Text(
                  'Estimated File Size',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              formattedSize,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (showDetails &&
                (videoStream != null || audioStream != null)) ...[
              const SizedBox(height: AppConstants.smallPadding),
              _buildSizeBreakdown(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSizeBreakdown(BuildContext context) {
    final theme = Theme.of(context);
    final breakdownItems = <Widget>[];

    if (videoStream != null) {
      final videoSize = _calculateVideoSize();
      breakdownItems.add(
        _buildBreakdownItem(
          context,
          'Video',
          videoStream!.qualityLevel,
          videoSize,
          Icons.video_file,
        ),
      );
    }

    if (audioStream != null) {
      final audioSize = _calculateAudioSize();
      breakdownItems.add(
        _buildBreakdownItem(
          context,
          'Audio',
          audioStream!.qualityLevel,
          audioSize,
          Icons.audio_file,
        ),
      );
    }

    return Column(children: breakdownItems);
  }

  Widget _buildBreakdownItem(
    BuildContext context,
    String type,
    String quality,
    int sizeBytes,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final formattedSize = _formatFileSize(sizeBytes);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$type ($quality)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ),
          Text(
            formattedSize,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Calculate total file size
  int _calculateTotalSize() {
    int totalSize = 0;

    if (videoStream != null) {
      totalSize += _calculateVideoSize();
    }

    if (audioStream != null) {
      totalSize += _calculateAudioSize();
    }

    return totalSize;
  }

  /// Calculate video file size
  int _calculateVideoSize() {
    if (videoStream == null || durationSeconds == null) return 0;

    return videoStream!.estimateFileSize(durationSeconds!);
  }

  /// Calculate audio file size
  int _calculateAudioSize() {
    if (audioStream == null || durationSeconds == null) return 0;

    return audioStream!.estimateFileSize(durationSeconds!);
  }

  /// Format file size in human readable format
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Widget for comparing file sizes between different formats
class FileSizeComparisonWidget extends StatelessWidget {
  final List<VideoStream> videoStreams;
  final List<AudioStream> audioStreams;
  final int? durationSeconds;
  final VideoStream? selectedVideoStream;
  final AudioStream? selectedAudioStream;

  const FileSizeComparisonWidget({
    super.key,
    required this.videoStreams,
    required this.audioStreams,
    this.durationSeconds,
    this.selectedVideoStream,
    this.selectedAudioStream,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.compare,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Text(
                  'File Size Comparison',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            if (videoStreams.isNotEmpty) ...[
              _buildVideoSizeComparison(context),
              const SizedBox(height: AppConstants.defaultPadding),
            ],
            if (audioStreams.isNotEmpty) ...[
              _buildAudioSizeComparison(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVideoSizeComparison(BuildContext context) {
    // Sort streams by quality (height) in descending order
    final sortedStreams = List<VideoStream>.from(videoStreams)
      ..sort((a, b) => b.height.compareTo(a.height));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Video Formats',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        ...sortedStreams.map(
          (stream) => _buildSizeComparisonItem(
            context,
            stream.qualityLevel,
            stream.displayResolution,
            stream.format.toUpperCase(),
            durationSeconds != null
                ? stream.estimateFileSize(durationSeconds!)
                : 0,
            selectedVideoStream?.id == stream.id,
          ),
        ),
      ],
    );
  }

  Widget _buildAudioSizeComparison(BuildContext context) {
    // Sort streams by bitrate in descending order
    final sortedStreams = List<AudioStream>.from(audioStreams)
      ..sort((a, b) => b.bitrate.compareTo(a.bitrate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Audio Formats',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        ...sortedStreams.map(
          (stream) => _buildSizeComparisonItem(
            context,
            stream.qualityLevel,
            stream.displayName,
            stream.format.toUpperCase(),
            durationSeconds != null
                ? stream.estimateFileSize(durationSeconds!)
                : 0,
            selectedAudioStream?.id == stream.id,
          ),
        ),
      ],
    );
  }

  Widget _buildSizeComparisonItem(
    BuildContext context,
    String quality,
    String description,
    String format,
    int sizeBytes,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    final formattedSize = _formatFileSize(sizeBytes);
    final cardColor = isSelected
        ? theme.primaryColor.withOpacity(0.1)
        : theme.cardColor;
    final borderColor = isSelected ? theme.primaryColor : theme.dividerColor;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quality,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$description • $format',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            formattedSize,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: AppConstants.smallPadding),
            Icon(Icons.check_circle, color: theme.primaryColor, size: 16),
          ],
        ],
      ),
    );
  }

  /// Format file size in human readable format
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
