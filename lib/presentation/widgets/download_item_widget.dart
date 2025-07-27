import 'package:flutter/material.dart';
import 'dart:io';
import '../../domain/entities/download_task.dart';
import '../../core/constants/download_status.dart';
import '../../core/utils/file_utils.dart';
import '../../core/utils/download_task_utils.dart';
import '../bloc/download_status/download_status_cubit.dart';
import 'dart:developer' as developer;

class DownloadItemWidget extends StatefulWidget {
  final DownloadTask download;
  final String title;
  final DownloadStatusCubit? cubit;

  const DownloadItemWidget({
    super.key,
    required this.download,
    required this.title,
    required this.cubit,
  });

  @override
  State<DownloadItemWidget> createState() => _DownloadItemWidgetState();
}

class _DownloadItemWidgetState extends State<DownloadItemWidget> {
  @override
  Widget build(BuildContext context) {
    final isMacOS = Platform.isMacOS;

    return FutureBuilder<bool>(
      future:
          widget.cubit?.isInSystemDownloads(widget.download.outputPath) ??
          Future.value(false),
      builder: (context, snapshot) {
        final isInSystemDownloads = snapshot.data ?? false;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, isMacOS, isInSystemDownloads),
                if (widget.download.status == DownloadStatus.downloading) ...[
                  const SizedBox(height: 12),
                  _buildProgressSection(context),
                ],
                if (widget.download.status == DownloadStatus.downloading) ...[
                  const SizedBox(height: 12),
                  _buildProgressDetails(context),
                ],
                const SizedBox(height: 12),
                _buildActionButtons(context, isInSystemDownloads),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isMacOS,
    bool isInSystemDownloads,
  ) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: widget.download.status.getColor(context),
          child: Icon(widget.download.status.icon, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.download.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${widget.download.format} • ${widget.download.quality}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (widget.title == 'Queued') ...[
                const SizedBox(height: 4),
                Text(
                  'Added: ${FileUtils.formatDateTime(widget.download.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (widget.download.status == DownloadStatus.completed) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isInSystemDownloads ? Icons.check_circle : Icons.info,
                      color: isInSystemDownloads
                          ? Colors.green.shade600
                          : Colors.blue.shade600,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isInSystemDownloads
                          ? 'System Downloads'
                          : isMacOS
                          ? 'App Documents'
                          : 'App Folder',
                      style: TextStyle(
                        color: isInSystemDownloads
                            ? Colors.green.shade700
                            : Colors.blue.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(widget.download.progress * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${FileUtils.formatFileSize(widget.download.bytesDownloaded)} / ${FileUtils.formatFileSize(widget.download.totalBytes)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: widget.download.progress,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.download.status.getColor(context),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Speed: ${DownloadTaskUtils.calculateSpeed(widget.download.bytesDownloaded, widget.download.startedAt ?? DateTime.now())}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'ETA: ${DownloadTaskUtils.calculateEta(widget.download.bytesDownloaded, widget.download.totalBytes, DownloadTaskUtils.calculateSpeed(widget.download.bytesDownloaded, widget.download.startedAt ?? DateTime.now()))}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressDetails(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDetailItem(
          context,
          Icons.schedule,
          'Started',
          FileUtils.formatDateTime(widget.download.startedAt),
        ),
        _buildDetailItem(
          context,
          Icons.format_list_bulleted,
          'Format',
          '${widget.download.format} • ${widget.download.quality}',
        ),
        _buildDetailItem(
          context,
          Icons.storage,
          'Size',
          FileUtils.formatFileSize(widget.download.totalBytes),
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

  Widget _buildActionButtons(BuildContext context, bool isInSystemDownloads) {
    final List<Widget> actionButtons = [];
    final isMacOS = Platform.isMacOS;

    // Add primary action button based on status
    if (widget.download.status == DownloadStatus.downloading) {
      actionButtons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => widget.cubit?.pauseDownload(widget.download.id),
            icon: const Icon(Icons.pause),
            label: const Text('Pause'),
          ),
        ),
      );
    } else if (widget.download.status == DownloadStatus.paused) {
      actionButtons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => widget.cubit?.resumeDownload(widget.download.id),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Resume'),
          ),
        ),
      );
    } else if (widget.download.status == DownloadStatus.completed) {
      actionButtons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              await widget.cubit?.openFile(widget.download.outputPath);
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open File'),
          ),
        ),
      );
    } else if (widget.download.status == DownloadStatus.failed) {
      actionButtons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Retry download
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ),
      );
    } else {
      // For queued status, add empty space
      actionButtons.add(const Expanded(child: SizedBox.shrink()));
    }

    // Add move to Downloads button for completed downloads on macOS
    if (widget.download.status == DownloadStatus.completed &&
        isMacOS &&
        !isInSystemDownloads) {
      if (actionButtons.isNotEmpty) {
        actionButtons.add(const SizedBox(width: 8));
      }
      actionButtons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              await _handleMoveToSystemDownloads(
                context,
                widget.download.outputPath,
              );
            },
            icon: const Icon(Icons.folder),
            label: const Text('Move to Downloads'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue.shade600,
            ),
          ),
        ),
      );
    }

    // Add cancel button for non-completed downloads
    if (widget.download.status != DownloadStatus.completed) {
      if (actionButtons.isNotEmpty) {
        actionButtons.add(const SizedBox(width: 8));
      }
      actionButtons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => widget.cubit?.cancelDownload(widget.download.id),
            icon: const Icon(Icons.stop),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      );
    }

    return Row(children: actionButtons);
  }

  Future<void> _handleMoveToSystemDownloads(
    BuildContext context,
    String filePath,
  ) async {
    try {
      if (!Platform.isMacOS) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Moving files to system Downloads is only supported on macOS',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final newPath = await widget.cubit?.moveToSystemDownloads(filePath);
      if (newPath != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File moved to Downloads successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the page to update the UI
        widget.cubit?.loadQueueStatus();
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to move file to Downloads'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      developer.log(
        '[download_item_widget.dart] - Error moving file to system downloads: $e',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error moving file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
