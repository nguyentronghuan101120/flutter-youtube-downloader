import 'package:flutter/material.dart';
import '../../domain/entities/download_task.dart';
import '../../core/services/download_service.dart';

class DownloadProgressWidget extends StatelessWidget {
  final DownloadTask task;
  final DownloadProgress? progress;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;

  const DownloadProgressWidget({
    super.key,
    required this.task,
    this.progress,
    this.onPause,
    this.onResume,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _buildStatusChip(context),
                    ],
                  ),
                ),
                _buildActionButtons(context),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            _buildProgressBar(context),
            const SizedBox(height: 8),

            // Progress details
            _buildProgressDetails(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color color;
    String text;

    switch (task.status) {
      case DownloadStatus.downloading:
        color = Colors.blue;
        text = 'Downloading';
        break;
      case DownloadStatus.paused:
        color = Colors.orange;
        text = 'Paused';
        break;
      case DownloadStatus.completed:
        color = Colors.green;
        text = 'Completed';
        break;
      case DownloadStatus.failed:
        color = Colors.red;
        text = 'Failed';
        break;
      case DownloadStatus.cancelled:
        color = Colors.grey;
        text = 'Cancelled';
        break;
      case DownloadStatus.pending:
        color = Colors.grey;
        text = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (task.status == DownloadStatus.downloading && onPause != null)
          IconButton(
            onPressed: onPause,
            icon: const Icon(Icons.pause),
            tooltip: 'Pause',
          ),
        if (task.status == DownloadStatus.paused && onResume != null)
          IconButton(
            onPressed: onResume,
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Resume',
          ),
        if (onCancel != null)
          IconButton(
            onPressed: onCancel,
            icon: const Icon(Icons.close),
            tooltip: 'Cancel',
          ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    double progressValue = 0.0;

    if (progress != null) {
      progressValue = progress!.percentage / 100;
    } else if (task.totalBytes > 0) {
      progressValue = task.bytesDownloaded / task.totalBytes;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: progressValue,
          backgroundColor: Colors.grey.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(context)),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progressValue * 100).toStringAsFixed(1)}%',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildProgressDetails(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildDetailItem(
            context,
            'Downloaded',
            _formatFileSize(task.bytesDownloaded),
            Icons.download,
          ),
        ),
        if (task.totalBytes > 0)
          Expanded(
            child: _buildDetailItem(
              context,
              'Total',
              _formatFileSize(task.totalBytes),
              Icons.storage,
            ),
          ),
        if (progress != null && progress!.speed > 0)
          Expanded(
            child: _buildDetailItem(
              context,
              'Speed',
              _formatDownloadSpeed(progress!.speed),
              Icons.speed,
            ),
          ),
        if (progress != null && progress!.estimatedTimeRemaining.inSeconds > 0)
          Expanded(
            child: _buildDetailItem(
              context,
              'ETA',
              _formatDuration(progress!.estimatedTimeRemaining),
              Icons.access_time,
            ),
          ),
      ],
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(BuildContext context) {
    switch (task.status) {
      case DownloadStatus.downloading:
        return Colors.blue;
      case DownloadStatus.paused:
        return Colors.orange;
      case DownloadStatus.completed:
        return Colors.green;
      case DownloadStatus.failed:
        return Colors.red;
      case DownloadStatus.cancelled:
        return Colors.grey;
      case DownloadStatus.pending:
        return Colors.grey;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDownloadSpeed(double bytesPerSecond) {
    if (bytesPerSecond < 1024)
      return '${bytesPerSecond.toStringAsFixed(1)} B/s';
    if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    }
    return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    }
    return '${duration.inSeconds}s';
  }
}
