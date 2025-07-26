import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../domain/entities/video_stream.dart';
import '../../domain/entities/audio_stream.dart';
import '../../core/utils/file_utils.dart';

class FormatSelectionWidget extends StatefulWidget {
  final List<VideoStream> videoStreams;
  final List<AudioStream> audioStreams;
  final Function(List<Map<String, String>> selectedFormats) onFormatsSelected;

  const FormatSelectionWidget({
    super.key,
    required this.videoStreams,
    required this.audioStreams,
    required this.onFormatsSelected,
  });

  @override
  State<FormatSelectionWidget> createState() => _FormatSelectionWidgetState();
}

class _FormatSelectionWidgetState extends State<FormatSelectionWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _selectedVideoFormats = {};
  final Set<String> _selectedAudioFormats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Video'),
            Tab(text: 'Audio'),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildVideoFormats(), _buildAudioFormats()],
          ),
        ),
        const SizedBox(height: 16),
        _buildDownloadButton(),
      ],
    );
  }

  Widget _buildVideoFormats() {
    // Debug: Print streams info
    developer.log(
      '[format_selection_widget.dart] - Video streams count: ${widget.videoStreams.length}',
    );
    for (int i = 0; i < widget.videoStreams.length; i++) {
      developer.log(
        '[format_selection_widget.dart] - Video stream $i: ${widget.videoStreams[i]}',
      );
    }

    if (widget.videoStreams.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No video formats available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Try analyzing the video again',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Hint about stream types
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Muxed: Video + Audio | Video-only: Video only (smaller file)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Video formats list
        Expanded(
          child: ListView.builder(
            itemCount: widget.videoStreams.length,
            itemBuilder: (context, index) {
              final stream = widget.videoStreams[index];
              // Create unique key using multiple properties to avoid conflicts
              final formatKey =
                  '${stream.format}_${stream.quality}_${stream.resolution}_${stream.fps}_${stream.fileSize}';
              final isSelected = _selectedVideoFormats.contains(formatKey);

              // Determine stream type based on bitrate and codec
              final isMuxed =
                  stream.bitrate >
                  1000000; // Muxed streams typically have higher bitrate
              final streamType = isMuxed ? 'Muxed' : 'Video-only';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedVideoFormats.add(formatKey);
                        } else {
                          _selectedVideoFormats.remove(formatKey);
                        }
                      });
                    },
                  ),
                  title: Row(
                    children: [
                      Text(
                        '${stream.format.toUpperCase()} - ${stream.quality}',
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isMuxed
                              ? Colors.blue.withValues(alpha: 0.1)
                              : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isMuxed ? Colors.blue : Colors.orange,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          streamType,
                          style: TextStyle(
                            fontSize: 10,
                            color: isMuxed ? Colors.blue : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${stream.resolution} • ${FileUtils.formatFileSize(stream.fileSize)}',
                      ),
                      Text(
                        '${stream.fps}fps • ${(stream.bitrate / 1000000).toStringAsFixed(1)} Mbps',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedVideoFormats.remove(formatKey);
                      } else {
                        _selectedVideoFormats.add(formatKey);
                      }
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAudioFormats() {
    // Debug: Print streams info
    developer.log(
      '[format_selection_widget.dart] - Audio streams count: ${widget.audioStreams.length}',
    );
    for (int i = 0; i < widget.audioStreams.length; i++) {
      developer.log(
        '[format_selection_widget.dart] - Audio stream $i: ${widget.audioStreams[i]}',
      );
    }

    if (widget.audioStreams.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.audiotrack, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No audio formats available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Try analyzing the video again',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: widget.audioStreams.length,
      itemBuilder: (context, index) {
        final stream = widget.audioStreams[index];
        // Create unique key using multiple properties to avoid conflicts
        final formatKey =
            '${stream.format}_${stream.bitrate}_${stream.channels}_${stream.sampleRate}_${stream.fileSize}';
        final isSelected = _selectedAudioFormats.contains(formatKey);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Checkbox(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedAudioFormats.add(formatKey);
                  } else {
                    _selectedAudioFormats.remove(formatKey);
                  }
                });
              },
            ),
            title: Text(
              '${stream.format.toUpperCase()} - ${stream.bitrate}kbps',
            ),
            subtitle: Text(
              '${stream.channels} channels • ${FileUtils.formatFileSize(stream.fileSize)}',
            ),
            trailing: Text(
              '${stream.sampleRate}Hz',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedAudioFormats.remove(formatKey);
                } else {
                  _selectedAudioFormats.add(formatKey);
                }
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildDownloadButton() {
    final selectedFormats = _tabController.index == 0
        ? _selectedVideoFormats
        : _selectedAudioFormats;
    final isEnabled = selectedFormats.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                final formats = _getSelectedFormatsList();
                widget.onFormatsSelected(formats);
              }
            : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Download ${selectedFormats.length} ${_tabController.index == 0 ? 'Video' : 'Audio'} Format${selectedFormats.length > 1 ? 's' : ''}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  List<Map<String, String>> _getSelectedFormatsList() {
    final List<Map<String, String>> formats = [];

    if (_tabController.index == 0) {
      // Video formats
      for (final formatKey in _selectedVideoFormats) {
        final parts = formatKey.split('_');
        if (parts.length >= 5) {
          formats.add({
            'format': parts[0],
            'quality': parts[1],
            'resolution': parts[2],
            'fps': parts[3],
            'fileSize': parts[4],
          });
        }
      }
    } else {
      // Audio formats
      for (final formatKey in _selectedAudioFormats) {
        final parts = formatKey.split('_');
        if (parts.length >= 5) {
          formats.add({
            'format': parts[0],
            'quality': parts[1],
            'channels': parts[2],
            'sampleRate': parts[3],
            'fileSize': parts[4],
          });
        }
      }
    }

    return formats;
  }
}
