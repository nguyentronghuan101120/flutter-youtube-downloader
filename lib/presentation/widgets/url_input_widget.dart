import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/video_analysis/video_analysis_cubit.dart';

class UrlInputWidget extends StatefulWidget {
  final Function(String) onUrlSubmitted;

  const UrlInputWidget({super.key, required this.onUrlSubmitted});

  @override
  State<UrlInputWidget> createState() => _UrlInputWidgetState();
}

class _UrlInputWidgetState extends State<UrlInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isValidUrl = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_validateUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validateUrl() {
    final url = _controller.text.trim();
    setState(() {
      _isValidUrl = url.isNotEmpty && _isValidYouTubeUrl(url);
    });
  }

  bool _isValidYouTubeUrl(String url) {
    final youtubeRegex = RegExp(
      r'^(https?://)?(www\.)?(youtube\.com|youtu\.be)/.+$',
      caseSensitive: false,
    );
    return youtubeRegex.hasMatch(url);
  }

  void _submitUrl() {
    final url = _controller.text.trim();
    if (_isValidUrl) {
      widget.onUrlSubmitted(url);
      _controller.clear();
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoAnalysisCubit, VideoAnalysisState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                labelText: 'Nhập URL YouTube',
                hintText: 'https://www.youtube.com/watch?v=...',
                prefixIcon: const Icon(Icons.link),
                suffixIcon: _isValidUrl
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.error, color: Colors.red),
                border: const OutlineInputBorder(),
                errorText: state is VideoAnalysisError ? state.message : null,
              ),
              onSubmitted: (_) => _submitUrl(),
              enabled: state is! VideoAnalysisLoading,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isValidUrl && state is! VideoAnalysisLoading
                  ? _submitUrl
                  : null,
              icon: state is VideoAnalysisLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(
                state is VideoAnalysisLoading
                    ? 'Đang phân tích...'
                    : 'Phân tích Video',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        );
      },
    );
  }
}
