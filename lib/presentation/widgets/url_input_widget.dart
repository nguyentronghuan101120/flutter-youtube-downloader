import 'package:flutter/material.dart';

class UrlInputWidget extends StatefulWidget {
  final Function(String) onUrlSubmitted;
  final bool isLoading;
  final String? errorMessage;

  const UrlInputWidget({
    super.key,
    required this.onUrlSubmitted,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  State<UrlInputWidget> createState() => _UrlInputWidgetState();
}

class _UrlInputWidgetState extends State<UrlInputWidget> {
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _urlFocusNode = FocusNode();
  bool _isValidUrl = false;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _urlController.addListener(_validateUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _urlFocusNode.dispose();
    super.dispose();
  }

  void _validateUrl() {
    final url = _urlController.text.trim();

    if (url.isEmpty) {
      setState(() {
        _isValidUrl = false;
        _validationMessage = null;
      });
      return;
    }

    final isValid = _isValidVideoUrl(url);
    final videoId = _extractVideoId(url);

    setState(() {
      _isValidUrl = isValid;
      if (!isValid) {
        _validationMessage = 'Please enter a valid YouTube video URL';
      } else if (videoId == null) {
        _validationMessage = 'Could not extract video ID from URL';
        _isValidUrl = false;
      } else {
        _validationMessage = 'Valid YouTube video URL';
      }
    });
  }

  /// Validates if the provided URL is a valid YouTube video URL
  bool _isValidVideoUrl(String url) {
    final youtubeVideoPattern = RegExp(
      r'^(https?://)?(www\.)?(youtube\.com/watch\?v=|youtu\.be/|youtube\.com/embed/)[a-zA-Z0-9_-]{11}.*$',
      caseSensitive: false,
    );
    return youtubeVideoPattern.hasMatch(url);
  }

  /// Extracts video ID from YouTube URL
  String? _extractVideoId(String url) {
    final patterns = [
      RegExp(
        r'(?:youtube\.com/watch\?v=|youtu\.be/|youtube\.com/embed/)([a-zA-Z0-9_-]{11})',
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }

  void _submitUrl() {
    final url = _urlController.text.trim();
    if (_isValidUrl && url.isNotEmpty) {
      widget.onUrlSubmitted(url);
    }
  }

  void _clearUrl() {
    _urlController.clear();
    setState(() {
      _isValidUrl = false;
      _validationMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // URL Input Field
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getBorderColor(), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _urlController,
            focusNode: _urlFocusNode,
            enabled: !widget.isLoading,
            decoration: InputDecoration(
              hintText: 'Enter YouTube video URL...',
              hintStyle: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              prefixIcon: Icon(Icons.link, color: _getIconColor()),
              suffixIcon: _buildSuffixIcon(),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onSubmitted: (_) => _submitUrl(),
            textInputAction: TextInputAction.done,
          ),
        ),

        const SizedBox(height: 8),

        // Validation Message
        if (_validationMessage != null)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Row(
              children: [
                Icon(
                  _isValidUrl ? Icons.check_circle : Icons.error,
                  size: 16,
                  color: _isValidUrl ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _validationMessage!,
                    style: TextStyle(
                      fontSize: 12,
                      color: _isValidUrl ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Error Message from Parent
        if (widget.errorMessage != null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Submit Button
        ElevatedButton(
          onPressed: _isValidUrl && !widget.isLoading ? _submitUrl : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: widget.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Analyze Video',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),

        const SizedBox(height: 16),

        // Help Text
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Supported URL formats:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildUrlExample('https://youtube.com/watch?v=VIDEO_ID'),
              _buildUrlExample('https://youtu.be/VIDEO_ID'),
              _buildUrlExample('https://youtube.com/embed/VIDEO_ID'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUrlExample(String example) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 4),
      child: Text(
        '• $example',
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_urlController.text.isNotEmpty) {
      return IconButton(
        icon: const Icon(Icons.clear),
        onPressed: _clearUrl,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      );
    }

    return null;
  }

  Color _getBorderColor() {
    if (widget.errorMessage != null) {
      return Colors.red;
    }
    if (_isValidUrl) {
      return Colors.green;
    }
    if (_urlController.text.isNotEmpty && !_isValidUrl) {
      return Colors.red;
    }
    return Theme.of(context).colorScheme.outline.withValues(alpha: 0.3);
  }

  Color _getIconColor() {
    if (widget.errorMessage != null) {
      return Colors.red;
    }
    if (_isValidUrl) {
      return Colors.green;
    }
    if (_urlController.text.isNotEmpty && !_isValidUrl) {
      return Colors.red;
    }
    return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
  }
}
