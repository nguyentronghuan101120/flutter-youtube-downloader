import 'package:flutter/material.dart';
import '../../core/constants/download_status.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;

  const EmptyStateWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_getEmptyStateIconForTab(title), size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No $title Downloads',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _getEmptyStateMessage(title),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getEmptyStateIconForTab(String title) {
    switch (title.toLowerCase()) {
      case 'active':
        return DownloadStatus.downloading.emptyStateIcon;
      case 'queued':
        return DownloadStatus.queued.emptyStateIcon;
      case 'completed':
        return DownloadStatus.completed.emptyStateIcon;
      default:
        return Icons.help;
    }
  }

  String _getEmptyStateMessage(String title) {
    switch (title.toLowerCase()) {
      case 'queued':
        return 'No downloads waiting in queue';
      default:
        return 'Your $title downloads will appear here';
    }
  }
}
