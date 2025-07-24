import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/download/download_cubit.dart';
import '../bloc/download/download_state.dart';
import '../widgets/format_selection_widget.dart';
import '../widgets/download_progress_widget.dart';
import '../../domain/entities/video_info.dart';
import '../../domain/entities/video_stream.dart';
import '../../domain/entities/audio_stream.dart';

class DownloadPage extends StatelessWidget {
  final VideoInfo videoInfo;

  const DownloadPage({super.key, required this.videoInfo});

  @override
  Widget build(BuildContext context) {
    // Prepare download when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DownloadCubit>().prepareDownload(videoInfo);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Download'),
        actions: [
          IconButton(
            icon: const Icon(Icons.queue),
            onPressed: () {
              context.read<DownloadCubit>().loadQueueStatus();
            },
          ),
        ],
      ),
      body: BlocBuilder<DownloadCubit, DownloadState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            analyzing: () => _buildAnalyzingState(),
            ready: (videoInfo, videoStreams, audioStreams) => _buildReadyState(
              context,
              videoInfo,
              videoStreams,
              audioStreams,
            ),
            downloading: (task, progress, speed, eta) =>
                _buildDownloadingState(context, task, progress, speed, eta),
            paused: (task, progress) =>
                _buildPausedState(context, task, progress),
            completed: (task, filePath) =>
                _buildCompletedState(context, task, filePath),
            failed: (message, task) =>
                _buildFailedState(context, message, task),
            queue: (activeDownloads, queuedDownloads, completedDownloads) =>
                _buildQueueState(
                  context,
                  activeDownloads,
                  queuedDownloads,
                  completedDownloads,
                ),
          );
        },
      ),
    );
  }

  Widget _buildAnalyzingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Analyzing video...'),
        ],
      ),
    );
  }

  Widget _buildReadyState(
    BuildContext context,
    VideoInfo videoInfo,
    List<VideoStream> videoStreams,
    List<AudioStream> audioStreams,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVideoInfo(context, videoInfo),
          const SizedBox(height: 24),
          Expanded(
            child: FormatSelectionWidget(
              videoStreams: videoStreams,
              audioStreams: audioStreams,
              onFormatSelected: (format, quality) {
                context.read<DownloadCubit>().startDownload(
                  url: videoInfo.url,
                  format: format,
                  quality: quality,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadingState(
    BuildContext context,
    dynamic task,
    double progress,
    String speed,
    String eta,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DownloadProgressWidget(
            task: task,
            progress: progress,
            speed: speed,
            eta: eta,
            onPause: () => context.read<DownloadCubit>().pauseDownload(task.id),
            onResume: () =>
                context.read<DownloadCubit>().resumeDownload(task.id),
            onCancel: () =>
                context.read<DownloadCubit>().cancelDownload(task.id),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildQueueList(context)),
        ],
      ),
    );
  }

  Widget _buildPausedState(
    BuildContext context,
    dynamic task,
    double progress,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DownloadProgressWidget(
            task: task,
            progress: progress,
            speed: '0 KB/s',
            eta: 'Paused',
            onResume: () =>
                context.read<DownloadCubit>().resumeDownload(task.id),
            onCancel: () =>
                context.read<DownloadCubit>().cancelDownload(task.id),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildQueueList(context)),
        ],
      ),
    );
  }

  Widget _buildCompletedState(
    BuildContext context,
    dynamic task,
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

  Widget _buildFailedState(BuildContext context, String message, dynamic task) {
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
    List<dynamic> activeDownloads,
    List<dynamic> queuedDownloads,
    List<dynamic> completedDownloads,
  ) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Queued'),
              Tab(text: 'Completed'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildDownloadList(activeDownloads),
                _buildDownloadList(queuedDownloads),
                _buildDownloadList(completedDownloads),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoInfo(BuildContext context, VideoInfo videoInfo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              videoInfo.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              videoInfo.author,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${videoInfo.duration} • ${videoInfo.viewCount} views',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueList(BuildContext context) {
    return const Center(child: Text('Download queue will appear here'));
  }

  Widget _buildDownloadList(List<dynamic> downloads) {
    if (downloads.isEmpty) {
      return const Center(child: Text('No downloads in this category'));
    }

    return ListView.builder(
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final download = downloads[index];
        return ListTile(
          title: Text(download.title),
          subtitle: Text('${download.format} • ${download.status}'),
          trailing: download.status == 'downloading'
              ? const CircularProgressIndicator()
              : null,
        );
      },
    );
  }
}
