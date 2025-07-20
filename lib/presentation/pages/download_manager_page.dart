import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/download/download_cubit.dart';
import '../bloc/download/download_state.dart';
import '../widgets/download_progress_widget.dart';
import '../widgets/download_queue_widget.dart';
import '../../core/services/download_service.dart';
import '../../domain/entities/download_task.dart';

class DownloadManagerPage extends StatelessWidget {
  const DownloadManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Manager'),
        actions: [
          IconButton(
            onPressed: () => _showSettings(context),
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: BlocBuilder<DownloadCubit, DownloadState>(
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDownload(context),
        child: const Icon(Icons.add),
        tooltip: 'Add Download',
      ),
    );
  }

  Widget _buildBody(BuildContext context, DownloadState state) {
    if (state is DownloadInitial) {
      return const Center(child: Text('No downloads available'));
    }

    if (state is DownloadQueueState) {
      return _buildDownloadList(context, state);
    }

    return const Center(child: Text('No downloads available'));
  }

  Widget _buildDownloadList(BuildContext context, DownloadQueueState state) {
    final activeDownloads = state.activeTasks;
    final queuedDownloads = state.queuedTasks;
    final completedDownloads = state.completedTasks;
    final failedDownloads = state.failedTasks;

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          // Tab bar
          Container(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: TabBar(
              isScrollable: true,
              tabs: [
                Tab(
                  text: 'Active (${activeDownloads.length})',
                  icon: const Icon(Icons.download),
                ),
                Tab(
                  text: 'Queue (${queuedDownloads.length})',
                  icon: const Icon(Icons.queue),
                ),
                Tab(
                  text: 'Completed (${completedDownloads.length})',
                  icon: const Icon(Icons.check_circle),
                ),
                Tab(
                  text: 'Failed (${failedDownloads.length})',
                  icon: const Icon(Icons.error),
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              children: [
                _buildActiveDownloads(context, activeDownloads),
                _buildQueuedDownloads(context, queuedDownloads),
                _buildCompletedDownloads(context, completedDownloads),
                _buildFailedDownloads(context, failedDownloads),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveDownloads(
    BuildContext context,
    List<DownloadTask> downloads,
  ) {
    if (downloads.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No active downloads'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final task = downloads[index];
        return DownloadProgressWidget(
          task: task,
          onPause: () => context.read<DownloadCubit>().pauseDownload(task.id),
          onCancel: () => context.read<DownloadCubit>().cancelDownload(task.id),
        );
      },
    );
  }

  Widget _buildQueuedDownloads(
    BuildContext context,
    List<DownloadTask> downloads,
  ) {
    if (downloads.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.queue_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No queued downloads'),
          ],
        ),
      );
    }

    return DownloadQueueWidget(
      downloads: downloads,
      onStart: (taskId) => context.read<DownloadCubit>().resumeDownload(taskId),
      onRemove: (taskId) =>
          context.read<DownloadCubit>().cancelDownload(taskId),
    );
  }

  Widget _buildCompletedDownloads(
    BuildContext context,
    List<DownloadTask> downloads,
  ) {
    if (downloads.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No completed downloads'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final task = downloads[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text(
              task.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              'Completed on ${_formatDate(task.completedAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) =>
                  _handleCompletedAction(context, task, value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'open',
                  child: Row(
                    children: [
                      Icon(Icons.open_in_new),
                      SizedBox(width: 8),
                      Text('Open File'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 8),
                      Text('Share'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFailedDownloads(
    BuildContext context,
    List<DownloadTask> downloads,
  ) {
    if (downloads.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No failed downloads'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final task = downloads[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.error, color: Colors.red),
            title: Text(
              task.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.errorMessage ?? 'Unknown error',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.red),
                ),
                Text(
                  'Failed on ${_formatDate(task.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleFailedAction(context, task, value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'retry',
                  child: Row(
                    children: [
                      Icon(Icons.refresh),
                      SizedBox(width: 8),
                      Text('Retry'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleCompletedAction(
    BuildContext context,
    DownloadTask task,
    String action,
  ) {
    switch (action) {
      case 'open':
        // TODO: Implement open file functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Open file not implemented yet')),
        );
        break;
      case 'share':
        // TODO: Implement share functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Share not implemented yet')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context, task);
        break;
    }
  }

  void _handleFailedAction(
    BuildContext context,
    DownloadTask task,
    String action,
  ) {
    switch (action) {
      case 'retry':
        context.read<DownloadCubit>().retryFailedDownload(task.id);
        break;
      case 'delete':
        _showDeleteConfirmation(context, task);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, DownloadTask task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Download'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<DownloadCubit>().cancelDownload(task.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    // TODO: Implement settings dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings not implemented yet')),
    );
  }

  void _showAddDownload(BuildContext context) {
    // TODO: Implement add download dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add download not implemented yet')),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }
}
