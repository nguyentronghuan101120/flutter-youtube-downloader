import 'package:flutter/material.dart';
import 'dart:io';
import '../../domain/entities/download_task.dart';
import 'download_progress_widget.dart';
import 'dart:developer' as developer;

class DownloadingStateWidget extends StatelessWidget {
  final DownloadTask task;
  final double progress;
  final String speed;
  final String eta;

  const DownloadingStateWidget({
    super.key,
    required this.task,
    required this.progress,
    required this.speed,
    required this.eta,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.download, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          Text(
            'Downloading: ${task.title}',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          DownloadProgressWidget(
            task: task,
            progress: progress,
            speed: speed,
            eta: eta,
          ),
        ],
      ),
    );
  }
}

class PausedStateWidget extends StatelessWidget {
  final DownloadTask task;
  final double progress;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;

  const PausedStateWidget({
    super.key,
    required this.task,
    required this.progress,
    this.onResume,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pause_circle, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            'Download Paused',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            task.title,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
          const SizedBox(height: 16),
          Text(
            '${(progress * 100).toStringAsFixed(1)}% Complete',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: onResume,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Resume'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.stop),
                label: const Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CompletedStateWidget extends StatelessWidget {
  final DownloadTask task;
  final String filePath;
  final Future<bool> Function(String)? isInSystemDownloads;
  final Future<void> Function(String)? onOpenFile;
  final Future<String?> Function(String)? onMoveToSystemDownloads;

  const CompletedStateWidget({
    super.key,
    required this.task,
    required this.filePath,
    this.isInSystemDownloads,
    this.onOpenFile,
    this.onMoveToSystemDownloads,
  });

  @override
  Widget build(BuildContext context) {
    final isMacOS = Platform.isMacOS;

    return FutureBuilder<bool>(
      future: isInSystemDownloads?.call(filePath) ?? Future.value(false),
      builder: (context, snapshot) {
        final isInSystemDownloads = snapshot.data ?? false;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 64, color: Colors.green),
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
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          isInSystemDownloads ? Icons.check_circle : Icons.info,
                          color: isInSystemDownloads
                              ? Colors.green.shade600
                              : Colors.blue.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isInSystemDownloads
                                ? 'File saved to system Downloads folder'
                                : isMacOS
                                ? 'File saved to app Documents folder'
                                : 'File saved to app folder',
                            style: TextStyle(
                              color: isInSystemDownloads
                                  ? Colors.green.shade700
                                  : Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      filePath,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    if (isMacOS && !isInSystemDownloads) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info,
                              color: Colors.blue.shade600,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'File automatically moved to system Downloads folder',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      await onOpenFile?.call(filePath);
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open File'),
                  ),
                  if (isMacOS && !isInSystemDownloads) ...[
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await _handleMoveToSystemDownloads(context, filePath);
                      },
                      icon: const Icon(Icons.folder),
                      label: const Text('Move to Downloads'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleMoveToSystemDownloads(
    BuildContext context,
    String filePath,
  ) async {
    try {
      if (!Platform.isMacOS) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Moving files to system Downloads is only supported on macOS',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final newPath = await onMoveToSystemDownloads?.call(filePath);
      if (newPath != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File moved to Downloads successfully'),
            backgroundColor: Colors.green,
          ),
        );
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
        '[download_state_widgets.dart] - Error moving file to system downloads: $e',
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

class FailedStateWidget extends StatelessWidget {
  final String message;
  final DownloadTask? task;
  final VoidCallback? onTryAgain;

  const FailedStateWidget({
    super.key,
    required this.message,
    this.task,
    this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Download Failed',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          if (task != null)
            Text(
              task!.title,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              children: [
                Text(
                  'Error:',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onTryAgain, child: const Text('Try Again')),
        ],
      ),
    );
  }
}
