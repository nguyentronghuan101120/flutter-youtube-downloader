import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/download_status/download_status_cubit.dart';
import '../bloc/download_status/download_status_state.dart';
import '../widgets/download_progress_widget.dart';
import '../../core/constants/download_status.dart';
import '../../core/utils/file_utils.dart';
import '../../core/utils/download_task_utils.dart';
import '../../domain/entities/download_task.dart';

class DownloadStatusPage extends StatefulWidget {
  const DownloadStatusPage({super.key});

  @override
  State<DownloadStatusPage> createState() => _DownloadStatusPageState();
}

class _DownloadStatusPageState extends State<DownloadStatusPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load queue status when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<DownloadStatusCubit>();
      cubit.loadQueueStatus();
      // Start faster periodic refresh
      cubit.startPeriodicRefresh();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when dependencies change (e.g., when returning to this page)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DownloadStatusCubit>().forceRefreshQueueStatus();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Stop periodic refresh when page is disposed
    context.read<DownloadStatusCubit>().stopPeriodicRefresh();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Status'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Queue'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: BlocBuilder<DownloadStatusCubit, DownloadStatusState>(
        buildWhen: (previous, current) {
          // Only rebuild if state actually changed
          return previous != current;
        },
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            downloading: (task, progress, speed, eta) =>
                _buildDownloadingState(context, task, progress, speed, eta),
            paused: (task, progress) =>
                _buildPausedState(context, task, progress),
            completed: (task, filePath) =>
                _buildCompletedState(context, task, filePath),
            failed: (message, task) =>
                _buildFailedState(context, message, task),
            queue: (activeDownloads, queuedDownloads, completedDownloads) {
              return _buildQueueState(
                context,
                activeDownloads,
                queuedDownloads,
                completedDownloads,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDownloadingState(
    BuildContext context,
    DownloadTask task,
    double progress,
    String speed,
    String eta,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Download progress widget
          DownloadProgressWidget(
            task: task,
            progress: progress,
            speed: speed,
            eta: eta,
            onPause: () =>
                context.read<DownloadStatusCubit>().pauseDownload(task.id),
            onResume: () =>
                context.read<DownloadStatusCubit>().resumeDownload(task.id),
            onCancel: () =>
                context.read<DownloadStatusCubit>().cancelDownload(task.id),
          ),
          const SizedBox(height: 16),
          // View all downloads button
          ElevatedButton.icon(
            onPressed: () {
              context.read<DownloadStatusCubit>().loadQueueStatus();
            },
            icon: const Icon(Icons.list),
            label: const Text('View All Downloads'),
          ),
        ],
      ),
    );
  }

  Widget _buildPausedState(
    BuildContext context,
    DownloadTask task,
    double progress,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DownloadProgressWidget(
        task: task,
        progress: progress,
        speed: '0 KB/s',
        eta: 'Paused',
        onResume: () =>
            context.read<DownloadStatusCubit>().resumeDownload(task.id),
        onCancel: () =>
            context.read<DownloadStatusCubit>().cancelDownload(task.id),
      ),
    );
  }

  Widget _buildCompletedState(
    BuildContext context,
    DownloadTask task,
    String filePath,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 64),
          const SizedBox(height: 16),
          Text(
            'Download Completed!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            task.title,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Open file or share
            },
            child: const Text('Open File'),
          ),
        ],
      ),
    );
  }

  Widget _buildFailedState(
    BuildContext context,
    String message,
    DownloadTask? task,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(
            'Download Failed',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueState(
    BuildContext context,
    List<DownloadTask> activeDownloads,
    List<DownloadTask> queuedDownloads,
    List<DownloadTask> completedDownloads,
  ) {
    // Create copies of lists and sort by creation time to maintain order
    final sortedActiveDownloads = List<DownloadTask>.from(activeDownloads)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final sortedQueuedDownloads = List<DownloadTask>.from(queuedDownloads)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final sortedCompletedDownloads = List<DownloadTask>.from(completedDownloads)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return TabBarView(
      controller: _tabController,
      children: [
        _buildDownloadList(context, sortedActiveDownloads, 'Active'),
        _buildDownloadList(context, sortedQueuedDownloads, 'Queued'),
        _buildDownloadList(context, sortedCompletedDownloads, 'Completed'),
      ],
    );
  }

  Widget _buildDownloadList(
    BuildContext context,
    List<DownloadTask> downloads,
    String title,
  ) {
    if (downloads.isEmpty) {
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
              title == 'Queued'
                  ? 'No downloads waiting in queue'
                  : 'Your $title downloads will appear here',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final download = downloads[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: download.status.getColor(context),
                      child: Icon(download.status.icon, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            download.title,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${download.format} • ${download.quality}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (title == 'Queued') ...[
                            const SizedBox(height: 4),
                            Text(
                              'Added: ${FileUtils.formatDateTime(download.createdAt)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                // Progress bar for downloading tasks
                if (download.status == DownloadStatus.downloading) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(download.progress * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '${FileUtils.formatFileSize(download.bytesDownloaded)} / ${FileUtils.formatFileSize(download.totalBytes)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: download.progress,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      download.status.getColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Speed: ${DownloadTaskUtils.calculateSpeed(download.bytesDownloaded, download.startedAt ?? DateTime.now())}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'ETA: ${DownloadTaskUtils.calculateEta(download.bytesDownloaded, download.totalBytes, DownloadTaskUtils.calculateSpeed(download.bytesDownloaded, download.startedAt ?? DateTime.now()))}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],

                // Progress details for downloading tasks
                if (download.status == DownloadStatus.downloading) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDetailItem(
                        context,
                        Icons.schedule,
                        'Started',
                        FileUtils.formatDateTime(download.startedAt),
                      ),
                      _buildDetailItem(
                        context,
                        Icons.format_list_bulleted,
                        'Format',
                        '${download.format} • ${download.quality}',
                      ),
                      _buildDetailItem(
                        context,
                        Icons.storage,
                        'Size',
                        FileUtils.formatFileSize(download.totalBytes),
                      ),
                    ],
                  ),
                ],

                // Action buttons
                const SizedBox(height: 12),
                _buildActionButtons(context, download),
              ],
            ),
          ),
        );
      },
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

  Widget _buildActionButtons(BuildContext context, DownloadTask download) {
    final List<Widget> actionButtons = [];

    // Add primary action button based on status
    if (download.status == DownloadStatus.downloading) {
      actionButtons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () =>
                context.read<DownloadStatusCubit>().pauseDownload(download.id),
            icon: const Icon(Icons.pause),
            label: const Text('Pause'),
          ),
        ),
      );
    } else if (download.status == DownloadStatus.paused) {
      actionButtons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () =>
                context.read<DownloadStatusCubit>().resumeDownload(download.id),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Resume'),
          ),
        ),
      );
    } else if (download.status == DownloadStatus.completed) {
      actionButtons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Open file
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open File'),
          ),
        ),
      );
    } else if (download.status == DownloadStatus.failed) {
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

    // Add cancel button for non-completed downloads
    if (download.status != DownloadStatus.completed) {
      if (actionButtons.isNotEmpty) {
        actionButtons.add(const SizedBox(width: 8));
      }
      actionButtons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () =>
                context.read<DownloadStatusCubit>().cancelDownload(download.id),
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
}
