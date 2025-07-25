import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../domain/entities/video_stream.dart';
import '../../domain/entities/audio_stream.dart';
import '../../core/utils/file_utils.dart';

class FormatSelectionWidget extends StatefulWidget {
  final List<VideoStream> videoStreams;
  final List<AudioStream> audioStreams;
  final Function(String format, String quality) onFormatSelected;

  const FormatSelectionWidget({
    super.key,
    required this.videoStreams,
    required this.audioStreams,
    required this.onFormatSelected,
  });

  @override
  State<FormatSelectionWidget> createState() => _FormatSelectionWidgetState();
}

class _FormatSelectionWidgetState extends State<FormatSelectionWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedVideoFormat;
  String? _selectedAudioFormat;
  String? _selectedQuality;

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

    return ListView.builder(
      itemCount: widget.videoStreams.length,
      itemBuilder: (context, index) {
        final stream = widget.videoStreams[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Radio<String>(
              value: '${stream.format}_${stream.quality}',
              groupValue:
                  _selectedVideoFormat != null && _selectedQuality != null
                  ? '${_selectedVideoFormat}_$_selectedQuality'
                  : null,
              onChanged: (value) {
                setState(() {
                  _selectedVideoFormat = stream.format;
                  _selectedQuality = stream.quality;
                });
              },
            ),
            title: Text('${stream.format.toUpperCase()} - ${stream.quality}'),
            subtitle: Text(
              '${stream.resolution} • ${FileUtils.formatFileSize(stream.fileSize)}',
            ),
            trailing: Text(
              '${stream.fps}fps',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () {
              setState(() {
                _selectedVideoFormat = stream.format;
                _selectedQuality = stream.quality;
              });
            },
          ),
        );
      },
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

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Radio<String>(
              value: '${stream.format}_${stream.bitrate}',
              groupValue:
                  _selectedAudioFormat != null && _selectedQuality != null
                  ? '${_selectedAudioFormat}_$_selectedQuality'
                  : null,
              onChanged: (value) {
                setState(() {
                  _selectedAudioFormat = stream.format;
                  _selectedQuality = stream.bitrate.toString();
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
                _selectedAudioFormat = stream.format;
                _selectedQuality = stream.bitrate.toString();
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildDownloadButton() {
    final format = _tabController.index == 0
        ? _selectedVideoFormat
        : _selectedAudioFormat;
    final isEnabled = format != null && _selectedQuality != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                widget.onFormatSelected(format, _selectedQuality!);
              }
            : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Download ${_tabController.index == 0 ? 'Video' : 'Audio'}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
