import 'package:flutter/material.dart';
import '../../domain/entities/video_stream.dart';
import '../../domain/entities/audio_stream.dart';
import '../../core/constants/app_constants.dart';

/// Widget for selecting video and audio formats with quality options
class FormatSelectionWidget extends StatefulWidget {
  final List<VideoStream> videoStreams;
  final List<AudioStream> audioStreams;
  final VideoStream? selectedVideoStream;
  final AudioStream? selectedAudioStream;
  final int? videoDuration;
  final Function(VideoStream?) onVideoStreamSelected;
  final Function(AudioStream?) onAudioStreamSelected;
  final bool showVideoOptions;
  final bool showAudioOptions;

  const FormatSelectionWidget({
    super.key,
    required this.videoStreams,
    required this.audioStreams,
    this.selectedVideoStream,
    this.selectedAudioStream,
    this.videoDuration,
    required this.onVideoStreamSelected,
    required this.onAudioStreamSelected,
    this.showVideoOptions = true,
    this.showAudioOptions = true,
  });

  @override
  State<FormatSelectionWidget> createState() => _FormatSelectionWidgetState();
}

class _FormatSelectionWidgetState extends State<FormatSelectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showVideoOptions && widget.videoStreams.isNotEmpty) ...[
          _buildSectionHeader('Video Format', Icons.video_file),
          const SizedBox(height: AppConstants.smallPadding),
          _buildVideoStreamList(),
          const SizedBox(height: AppConstants.defaultPadding),
        ],
        if (widget.showAudioOptions && widget.audioStreams.isNotEmpty) ...[
          _buildSectionHeader('Audio Format', Icons.audio_file),
          const SizedBox(height: AppConstants.smallPadding),
          _buildAudioStreamList(),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
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

  Widget _buildVideoStreamList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.videoStreams.length,
      itemBuilder: (context, index) {
        final stream = widget.videoStreams[index];
        final isSelected = widget.selectedVideoStream?.id == stream.id;

        return _buildVideoStreamCard(stream, isSelected);
      },
    );
  }

  Widget _buildVideoStreamCard(VideoStream stream, bool isSelected) {
    final theme = Theme.of(context);
    final cardColor = isSelected
        ? theme.primaryColor.withOpacity(0.1)
        : theme.cardColor;
    final borderColor = isSelected ? theme.primaryColor : theme.dividerColor;

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        side: BorderSide(color: borderColor, width: isSelected ? 2 : 1),
      ),
      child: InkWell(
        onTap: () => widget.onVideoStreamSelected(stream),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildQualityBadge(stream.qualityLevel),
                            const SizedBox(width: AppConstants.smallPadding),
                            Text(
                              stream.displayResolution,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (stream.fps != null) ...[
                              const SizedBox(width: AppConstants.smallPadding),
                              Text(
                                '${stream.fps} FPS',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${stream.codec} • ${stream.format.toUpperCase()} • ${stream.formattedBitrate}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: theme.primaryColor,
                      size: 24,
                    ),
                ],
              ),
              if (widget.videoDuration != null) ...[
                const SizedBox(height: AppConstants.smallPadding),
                Row(
                  children: [
                    Icon(
                      Icons.storage,
                      size: 16,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Estimated size: ${stream.getFormattedFileSize(widget.videoDuration!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioStreamList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.audioStreams.length,
      itemBuilder: (context, index) {
        final stream = widget.audioStreams[index];
        final isSelected = widget.selectedAudioStream?.id == stream.id;

        return _buildAudioStreamCard(stream, isSelected);
      },
    );
  }

  Widget _buildAudioStreamCard(AudioStream stream, bool isSelected) {
    final theme = Theme.of(context);
    final cardColor = isSelected
        ? theme.primaryColor.withOpacity(0.1)
        : theme.cardColor;
    final borderColor = isSelected ? theme.primaryColor : theme.dividerColor;

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        side: BorderSide(color: borderColor, width: isSelected ? 2 : 1),
      ),
      child: InkWell(
        onTap: () => widget.onAudioStreamSelected(stream),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildQualityBadge(stream.qualityLevel),
                            const SizedBox(width: AppConstants.smallPadding),
                            Text(
                              stream.displayName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${stream.codec} • ${stream.format.toUpperCase()} • ${stream.formattedBitrate} • ${stream.channelConfig}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                        if (stream.language != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Language: ${stream.language}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: theme.primaryColor,
                      size: 24,
                    ),
                ],
              ),
              if (widget.videoDuration != null) ...[
                const SizedBox(height: AppConstants.smallPadding),
                Row(
                  children: [
                    Icon(
                      Icons.storage,
                      size: 16,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Estimated size: ${stream.getFormattedFileSize(widget.videoDuration!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        quality,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
