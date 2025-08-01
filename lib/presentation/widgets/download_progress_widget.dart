import 'package:flutter/material.dart';
import '../../domain/entities/download_task.dart';
import '../../core/constants/download_status.dart';
import '../../core/utils/file_utils.dart';

class DownloadProgressWidget extends StatelessWidget {
  final DownloadTask task;
  final double progress;
  final String speed;
  final String eta;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;

  const DownloadProgressWidget({
    super.key,
    required this.task,
    required this.progress,
    required this.speed,
    required this.eta,
    this.onPause,
    this.onResume,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildProgressBar(context),
            const SizedBox(height: 16),
            _buildProgressDetails(context),
            const SizedBox(height: 16),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(task.status.icon, color: task.status.getColor(context)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            task.title,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${FileUtils.formatFileSize(task.bytesDownloaded)} / ${FileUtils.formatFileSize(task.totalBytes)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(
            task.status.getColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressDetails(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDetailItem(context, Icons.speed, 'Speed', speed),
        _buildDetailItem(context, Icons.timer, 'ETA', eta),
        _buildDetailItem(
          context,
          Icons.format_list_bulleted,
          'Format',
          task.format,
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final List<Widget> actionButtons = [];

    // Add primary action button based on status
    if (task.status == DownloadStatus.downloading) {
      actionButtons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPause,
            icon: const Icon(Icons.pause),
            label: const Text('Pause'),
          ),
        ),
      );
    } else if (task.status == DownloadStatus.paused) {
      actionButtons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onResume,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Resume'),
          ),
        ),
      );
    } else {
      // For other statuses, add empty space
      actionButtons.add(const Expanded(child: SizedBox.shrink()));
    }

    // Add cancel button
    if (actionButtons.isNotEmpty) {
      actionButtons.add(const SizedBox(width: 8));
    }
    actionButtons.add(
      Expanded(
        child: OutlinedButton.icon(
          onPressed: onCancel,
          icon: const Icon(Icons.stop),
          label: const Text('Cancel'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );

    return Row(children: actionButtons);
  }
}
