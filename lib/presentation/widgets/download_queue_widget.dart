import 'package:flutter/material.dart';
import '../../domain/entities/download_task.dart';

class DownloadQueueWidget extends StatelessWidget {
  final List<DownloadTask> downloads;
  final Function(String) onStart;
  final Function(String) onRemove;

  const DownloadQueueWidget({
    super.key,
    required this.downloads,
    required this.onStart,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final task = downloads[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.queue, color: Colors.orange),
            title: Text(
              task.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Queued on ${_formatDate(task.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (task.totalBytes > 0)
                  Text(
                    'Size: ${_formatFileSize(task.totalBytes)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => onStart(task.id),
                  icon: const Icon(Icons.play_arrow),
                  tooltip: 'Start Download',
                ),
                IconButton(
                  onPressed: () => onRemove(task.id),
                  icon: const Icon(Icons.remove_circle_outline),
                  tooltip: 'Remove from Queue',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
