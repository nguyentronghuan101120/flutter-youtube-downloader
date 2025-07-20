import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/video_analysis/video_analysis_cubit.dart';

class UrlInputWidget extends StatefulWidget {
  const UrlInputWidget({super.key});

  @override
  State<UrlInputWidget> createState() => _UrlInputWidgetState();
}

class _UrlInputWidgetState extends State<UrlInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _analyzeVideo() {
    if (_formKey.currentState!.validate()) {
      final url = _controller.text.trim();
      context.read<VideoAnalysisCubit>().analyzeVideo(url);
    }
  }

  void _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      setState(() {
        _controller.text = clipboardData!.text!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Enter YouTube URL',
              hintText: 'https://youtube.com/watch?v=...',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.paste),
                onPressed: _pasteFromClipboard,
                tooltip: 'Paste from clipboard',
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a YouTube URL';
              }
              if (!value.contains('youtube.com') &&
                  !value.contains('youtu.be')) {
                return 'Please enter a valid YouTube URL';
              }
              return null;
            },
            onFieldSubmitted: (_) => _analyzeVideo(),
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
}
