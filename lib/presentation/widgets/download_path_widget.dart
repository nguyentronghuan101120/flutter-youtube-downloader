import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/dependency_injection/injection.dart';
import '../bloc/download_path/download_path_cubit.dart';
import '../bloc/download_path/download_path_state.dart';

class DownloadPathWidget extends StatelessWidget {
  const DownloadPathWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DownloadPathCubit>()..loadDownloadPath(),
      child: BlocBuilder<DownloadPathCubit, DownloadPathState>(
        builder: (context, state) {
          return Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.folder, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Download Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: state.maybeWhen(
                          loading: () => null,
                          orElse: () =>
                              () => context
                                  .read<DownloadPathCubit>()
                                  .refreshDownloadPath(),
                        ),
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Refresh',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  state.when(
                    initial: () => const SizedBox.shrink(),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    loaded: (path, systemDownloadsPath) =>
                        _buildPathInfo(path, systemDownloadsPath),
                    error: (message) => _buildErrorWidget(message),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Files will be saved to this location when downloading videos.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPathInfo(String path, String? systemDownloadsPath) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600),
              const SizedBox(width: 8),
              const Text(
                'Download Path:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            path,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            _isSystemDownloadsPath(path)
                ? '✅ Using system Downloads folder'
                : '⚠️ Using app-specific folder',
            style: TextStyle(
              color: _isSystemDownloadsPath(path)
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
              fontSize: 12,
            ),
          ),
          if (systemDownloadsPath != null && !_isSystemDownloadsPath(path)) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade600, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'System Downloads Available:',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(
              systemDownloadsPath,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '💡 You can manually move downloaded files to the system Downloads folder',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Error: $error',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSystemDownloadsPath(String path) {
    // Check if the path contains system downloads indicators
    return path.contains('/storage/emulated/0/Download') ||
        path.contains('/sdcard/Download') ||
        path.contains('/Download') ||
        path.contains('/Downloads');
  }
}
