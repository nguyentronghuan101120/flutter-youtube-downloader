import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/download_status/download_status_cubit.dart';
import '../bloc/download_status/download_status_state.dart';
import '../widgets/download_state_widgets.dart';
import '../widgets/download_list_widget.dart';
import '../../domain/entities/download_task.dart';

class DownloadStatusPage extends StatefulWidget {
  const DownloadStatusPage({super.key});

  @override
  State<DownloadStatusPage> createState() => _DownloadStatusPageState();
}

class _DownloadStatusPageState extends State<DownloadStatusPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DownloadStatusCubit? _cubit;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save reference to cubit for safe access in dispose
    _cubit = context.read<DownloadStatusCubit>();

    // Load queue status when page loads (only once)
    if (_cubit != null && !_isInitialized) {
      _isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _cubit != null) {
          _cubit!.loadQueueStatus();
          // Start faster periodic refresh
          _cubit!.startPeriodicRefresh();
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Stop periodic refresh when page is disposed - use saved reference
    _cubit?.stopPeriodicRefresh();
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
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            downloading: (task, progress, speed, eta) => DownloadingStateWidget(
              task: task,
              progress: progress,
              speed: speed,
              eta: eta,
            ),
            paused: (task, progress) => PausedStateWidget(
              task: task,
              progress: progress,
              onResume: () => _cubit?.resumeDownload(task.id),
              onCancel: () => _cubit?.cancelDownload(task.id),
            ),
            completed: (task, filePath) => CompletedStateWidget(
              task: task,
              filePath: filePath,
              isInSystemDownloads: (path) =>
                  _cubit?.isInSystemDownloads(path) ?? Future.value(false),
              onOpenFile: (path) => _cubit?.openFile(path) ?? Future.value(),
              onMoveToSystemDownloads: (path) async {
                final result = await _cubit?.moveToSystemDownloads(path);
                return result;
              },
            ),
            failed: (message, task) => FailedStateWidget(
              message: message,
              task: task,
              onTryAgain: () => Navigator.pop(context),
            ),
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
        DownloadListWidget(
          downloads: sortedActiveDownloads,
          title: 'Active',
          cubit: _cubit,
        ),
        DownloadListWidget(
          downloads: sortedQueuedDownloads,
          title: 'Queued',
          cubit: _cubit,
        ),
        DownloadListWidget(
          downloads: sortedCompletedDownloads,
          title: 'Completed',
          cubit: _cubit,
        ),
      ],
    );
  }
}
