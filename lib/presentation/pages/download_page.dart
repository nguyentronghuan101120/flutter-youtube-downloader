import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/download/download_cubit.dart';
import '../bloc/download/download_state.dart';
import '../bloc/download_status/download_status_cubit.dart';
import '../widgets/format_selection_widget.dart';
import '../widgets/common_button.dart';
import '../../domain/entities/video_info.dart';
import '../../core/dependency_injection/injection.dart';
import 'download_status_page.dart';

class DownloadPage extends StatelessWidget {
  final VideoInfo videoInfo;

  const DownloadPage({super.key, required this.videoInfo});

  @override
  Widget build(BuildContext context) {
    // Prepare download when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Prepare download for the current video
      context.read<DownloadCubit>().prepareDownload(videoInfo);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Download'),
        actions: [
          IconButton(
            icon: const Icon(Icons.queue),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => getIt<DownloadStatusCubit>(),
                    child: const DownloadStatusPage(),
                  ),
                ),
              );
              // Refresh the current page state when returning
              if (context.mounted) {
                // Prepare download for the current video
                context.read<DownloadCubit>().prepareDownload(videoInfo);
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<DownloadCubit, DownloadState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            ready: (videoInfo, videoStreams, audioStreams) => Padding(
              padding: const EdgeInsets.all(16),
              child: FormatSelectionWidget(
                videoStreams: videoStreams,
                audioStreams: audioStreams,
                onFormatsSelected: (selectedFormats) async {
                  // Add to download queue
                  await context.read<DownloadCubit>().startMultipleDownloads(
                    url: videoInfo.url,
                    formats: selectedFormats,
                  );

                  // Navigate to download status page
                  if (!context.mounted) return;

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => getIt<DownloadStatusCubit>(),
                        child: const DownloadStatusPage(),
                      ),
                    ),
                  );

                  // Refresh the current page state when returning
                  if (context.mounted) {
                    context.read<DownloadCubit>().prepareDownload(videoInfo);
                  }
                },
              ),
            ),
            failed: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Error',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  CommonButton(
                    text: 'Try Again',
                    onPressed: () {
                      context.read<DownloadCubit>().prepareDownload(videoInfo);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
