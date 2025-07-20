import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../bloc/video_analysis/video_analysis_cubit.dart';

class UrlInputWidget extends StatefulWidget {
  final DownloadType? selectedDownloadType;
  final Function(DownloadType) onDownloadTypeChanged;
  final Function(String format, String quality)? onFormatSelected;

  const UrlInputWidget({
    super.key,
    this.selectedDownloadType,
    required this.onDownloadTypeChanged,
    this.onFormatSelected,
  });

  @override
  State<UrlInputWidget> createState() => _UrlInputWidgetState();
}

class _UrlInputWidgetState extends State<UrlInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late DownloadType _selectedDownloadType;
  String _selectedFormat = 'MP4';
  String _selectedQuality = '1080p';
  String? _errorMessage; // Thêm state cho error message

  @override
  void initState() {
    super.initState();
    _selectedDownloadType =
        widget.selectedDownloadType ?? DownloadType.videoOnly;
    _updateDefaultFormat();
  }

  void _updateDefaultFormat() {
    if (_selectedDownloadType == DownloadType.audioOnly) {
      _selectedFormat = 'MP3';
      _selectedQuality = '';
    } else {
      _selectedFormat = 'MP4';
      _selectedQuality = '1080p';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _analyzeVideo() {
    _validateUrl(_controller.text);
    if (_errorMessage == null) {
      final url = _controller.text.trim();
      context.read<VideoAnalysisCubit>().analyzeVideo(url);
    }
  }

  void _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      setState(() {
        _controller.text = clipboardData!.text!;
        _errorMessage = null; // Clear error khi paste
      });
    }
  }

  void _onDownloadTypeChanged(DownloadType? newType) {
    if (newType != null && newType != _selectedDownloadType) {
      setState(() {
        _selectedDownloadType = newType;
      });
      _updateDefaultFormat();
      widget.onDownloadTypeChanged(newType);
    }
  }

  void _onFormatChanged(String? newFormat) {
    if (newFormat != null && newFormat != _selectedFormat) {
      setState(() {
        _selectedFormat = newFormat;
        // Cập nhật quality mặc định cho format mới
        if (_selectedDownloadType == DownloadType.audioOnly) {
          _selectedQuality = '';
        } else {
          _selectedQuality = '1080p';
        }
      });
      widget.onFormatSelected?.call(_selectedFormat, _selectedQuality);
    }
  }

  void _onQualityChanged(String? newQuality) {
    if (newQuality != null && newQuality != _selectedQuality) {
      setState(() {
        _selectedQuality = newQuality;
      });
      widget.onFormatSelected?.call(_selectedFormat, _selectedQuality);
    }
  }

  void _validateUrl(String? value) {
    setState(() {
      if (value == null || value.trim().isEmpty) {
        _errorMessage = 'Please enter a YouTube URL';
      } else if (!value.contains('youtube.com') &&
          !value.contains('youtu.be')) {
        _errorMessage = 'Please enter a valid YouTube URL';
      } else {
        _errorMessage = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Download type dropdown
          DropdownButtonFormField<DownloadType>(
            value: _selectedDownloadType,
            decoration: const InputDecoration(
              labelText: 'Download Type',
              border: OutlineInputBorder(),
            ),
            items: DownloadType.values.map((type) {
              return DropdownMenuItem<DownloadType>(
                value: type,
                child: Row(
                  children: [
                    Icon(
                      type == DownloadType.audioOnly
                          ? Icons.audiotrack
                          : Icons.video_file,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type == DownloadType.audioOnly
                          ? 'Audio Only'
                          : 'Video Only',
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: _onDownloadTypeChanged,
          ),
          const SizedBox(height: 16),

          // Format dropdown
          DropdownButtonFormField<String>(
            value: _selectedFormat,
            decoration: const InputDecoration(
              labelText: 'Format',
              border: OutlineInputBorder(),
            ),
            items: _getFormatOptions().map((format) {
              return DropdownMenuItem<String>(
                value: format,
                child: Row(
                  children: [
                    Icon(
                      _selectedDownloadType == DownloadType.audioOnly
                          ? Icons.audiotrack
                          : Icons.video_file,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(format),
                  ],
                ),
              );
            }).toList(),
            onChanged: _onFormatChanged,
          ),
          const SizedBox(height: 16),

          // Quality dropdown (chỉ hiển thị cho video)
          if (_selectedDownloadType == DownloadType.videoOnly) ...[
            DropdownButtonFormField<String>(
              value: _selectedQuality,
              decoration: const InputDecoration(
                labelText: 'Quality',
                border: OutlineInputBorder(),
              ),
              items: _getQualityOptions().map((quality) {
                return DropdownMenuItem<String>(
                  value: quality,
                  child: Text(quality),
                );
              }).toList(),
              onChanged: _onQualityChanged,
            ),
            const SizedBox(height: 16),
          ],

          // URL input field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56, // Cố định chiều cao bằng với buttons
                      child: TextFormField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: 'Enter YouTube URL',
                          hintText: 'https://youtube.com/watch?v=...',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          errorStyle: const TextStyle(
                            height: 0,
                          ), // Ẩn error style mặc định
                        ),
                        onChanged: _validateUrl,
                        onFieldSubmitted: (_) => _analyzeVideo(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Paste button
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green[600]!, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: _pasteFromClipboard,
                        icon: Icon(
                          Icons.paste,
                          color: Colors.green[600],
                          size: 24,
                        ),
                        tooltip: 'Paste from clipboard',
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Clear button
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red[600]!, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _controller.clear();
                          });
                        },
                        icon: Icon(
                          Icons.clear,
                          color: Colors.red[600],
                          size: 24,
                        ),
                        tooltip: 'Clear URL',
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Custom error message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _analyzeVideo,
              icon: const Icon(Icons.search),
              label: const Text('Analyze Video'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getFormatOptions() {
    if (_selectedDownloadType == DownloadType.audioOnly) {
      return ['MP3', 'M4A', 'WEBM', 'AAC', 'FLAC', 'OPUS', 'OGG', 'WAV'];
    } else {
      return ['MP4', 'WEBM'];
    }
  }

  List<String> _getQualityOptions() {
    return ['144p', '240p', '360p', '480p', '720p', '1080p', '1440p', '4K'];
  }
}
