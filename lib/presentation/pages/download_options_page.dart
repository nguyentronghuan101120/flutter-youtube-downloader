import 'package:flutter/material.dart';
import '../../domain/entities/video_stream.dart' as stream_entities;
import '../../domain/entities/audio_stream.dart' as stream_entities;
import '../../domain/entities/video_info.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/format_selection_widget.dart';
import '../widgets/quality_comparison_widget.dart';

/// Page for selecting download options and formats
class DownloadOptionsPage extends StatefulWidget {
  final VideoInfo videoInfo;
  final List<stream_entities.VideoStream> videoStreams;
  final List<stream_entities.AudioStream> audioStreams;

  const DownloadOptionsPage({
    super.key,
    required this.videoInfo,
    required this.videoStreams,
    required this.audioStreams,
  });

  @override
  State<DownloadOptionsPage> createState() => _DownloadOptionsPageState();
}

class _DownloadOptionsPageState extends State<DownloadOptionsPage> {
  stream_entities.VideoStream? selectedVideoStream;
  stream_entities.AudioStream? selectedAudioStream;
  String downloadPath = AppConstants.defaultDownloadPath;
  String fileName = '';
  bool showComparison = false;
  bool downloadVideoOnly = false;
  bool downloadAudioOnly = false;

  @override
  void initState() {
    super.initState();
    _initializeSelections();
    _generateFileName();
  }

  void _initializeSelections() {
    // Auto-select best quality video and audio
    if (widget.videoStreams.isNotEmpty) {
      selectedVideoStream = widget.videoStreams.first;
    }
    if (widget.audioStreams.isNotEmpty) {
      selectedAudioStream = widget.audioStreams.first;
    }
  }

  void _generateFileName() {
    final title = widget.videoInfo.title
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    fileName = title.isNotEmpty ? title : 'youtube_video';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Options'),
        actions: [
          IconButton(
            icon: Icon(showComparison ? Icons.list : Icons.compare),
            onPressed: () {
              setState(() {
                showComparison = !showComparison;
              });
            },
            tooltip: showComparison ? 'Show List View' : 'Show Comparison',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVideoInfoCard(),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildDownloadTypeSelector(),
            const SizedBox(height: AppConstants.defaultPadding),
            if (showComparison)
              _buildComparisonView()
            else
              _buildFormatSelectionView(),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildDownloadOptions(),
            const SizedBox(height: AppConstants.largePadding),
            _buildDownloadButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (widget.videoInfo.thumbnailUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                    child: Image.network(
                      widget.videoInfo.thumbnailUrl,
                      width: 80,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.video_file),
                        );
                      },
                    ),
                  ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.videoInfo.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.videoInfo.channelName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                      if (widget.videoInfo.duration != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _formatDuration(widget.videoInfo.duration.inSeconds),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color?.withOpacity(0.7),
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Download Type',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Row(
              children: [
                Expanded(
                  child: _buildDownloadTypeOption(
                    'Video Only',
                    Icons.video_file,
                    downloadVideoOnly,
                    (value) {
                      setState(() {
                        downloadVideoOnly = value;
                        if (value) downloadAudioOnly = false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Expanded(
                  child: _buildDownloadTypeOption(
                    'Audio Only',
                    Icons.audio_file,
                    downloadAudioOnly,
                    (value) {
                      setState(() {
                        downloadAudioOnly = value;
                        if (value) downloadVideoOnly = false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Expanded(
                  child: _buildDownloadTypeOption(
                    'Both',
                    Icons.video_library,
                    !downloadVideoOnly && !downloadAudioOnly,
                    (value) {
                      setState(() {
                        if (value) {
                          downloadVideoOnly = false;
                          downloadAudioOnly = false;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadTypeOption(
    String title,
    IconData icon,
    bool isSelected,
    Function(bool) onChanged,
  ) {
    final theme = Theme.of(context);
    final cardColor = isSelected
        ? theme.primaryColor.withOpacity(0.1)
        : theme.cardColor;
    final borderColor = isSelected ? theme.primaryColor : theme.dividerColor;

    return InkWell(
      onTap: () => onChanged(!isSelected),
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.smallPadding),
        decoration: BoxDecoration(
          color: cardColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? theme.primaryColor : null, size: 24),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? theme.primaryColor : null,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatSelectionView() {
    return FormatSelectionWidget(
      videoStreams:
          downloadVideoOnly || (!downloadVideoOnly && !downloadAudioOnly)
          ? widget.videoStreams
          : [],
      audioStreams:
          downloadAudioOnly || (!downloadVideoOnly && !downloadAudioOnly)
          ? widget.audioStreams
          : [],
      selectedVideoStream: selectedVideoStream,
      selectedAudioStream: selectedAudioStream,
      videoDuration: widget.videoInfo.duration.inSeconds,
      onVideoStreamSelected: (stream) {
        setState(() {
          selectedVideoStream = stream;
        });
      },
      onAudioStreamSelected: (stream) {
        setState(() {
          selectedAudioStream = stream;
        });
      },
      showVideoOptions:
          downloadVideoOnly || (!downloadVideoOnly && !downloadAudioOnly),
      showAudioOptions:
          downloadAudioOnly || (!downloadVideoOnly && !downloadAudioOnly),
    );
  }

  Widget _buildComparisonView() {
    return QualityComparisonWidget(
      videoStreams:
          downloadVideoOnly || (!downloadVideoOnly && !downloadAudioOnly)
          ? widget.videoStreams
          : [],
      audioStreams:
          downloadAudioOnly || (!downloadVideoOnly && !downloadAudioOnly)
          ? widget.audioStreams
          : [],
      videoDuration: widget.videoInfo.duration.inSeconds,
      selectedVideoStream: selectedVideoStream,
      selectedAudioStream: selectedAudioStream,
    );
  }

  Widget _buildDownloadOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Download Options',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildTextField('File Name', fileName, Icons.edit, (value) {
              setState(() {
                fileName = value;
              });
            }),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildTextField('Download Path', downloadPath, Icons.folder, (
              value,
            ) {
              setState(() {
                downloadPath = value;
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String value,
    IconData icon,
    Function(String) onChanged,
  ) {
    return TextField(
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildDownloadButton() {
    final canDownload =
        (downloadVideoOnly && selectedVideoStream != null) ||
        (downloadAudioOnly && selectedAudioStream != null) ||
        (!downloadVideoOnly &&
            !downloadAudioOnly &&
            (selectedVideoStream != null || selectedAudioStream != null));

    return SizedBox(
      width: double.infinity,
      height: AppConstants.buttonHeight,
      child: ElevatedButton(
        onPressed: canDownload ? _startDownload : null,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
        child: const Text(
          'Start Download',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _startDownload() {
    // TODO: Implement download functionality
    final selectedFormats = <String>[];

    if (selectedVideoStream != null) {
      selectedFormats.add(
        'Video: ${selectedVideoStream!.qualityLevel} ${selectedVideoStream!.format.toUpperCase()}',
      );
    }

    if (selectedAudioStream != null) {
      selectedFormats.add(
        'Audio: ${selectedAudioStream!.qualityLevel} ${selectedAudioStream!.format.toUpperCase()}',
      );
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Started'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File: $fileName'),
            Text('Path: $downloadPath'),
            const SizedBox(height: 8),
            const Text('Selected formats:'),
            ...selectedFormats.map((format) => Text('• $format')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }
}
