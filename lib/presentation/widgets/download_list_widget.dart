import 'package:flutter/material.dart';
import '../../domain/entities/download_task.dart';
import '../bloc/download_status/download_status_cubit.dart';
import 'download_item_widget.dart';
import 'empty_state_widget.dart';

class DownloadListWidget extends StatelessWidget {
  final List<DownloadTask> downloads;
  final String title;
  final DownloadStatusCubit? cubit;

  const DownloadListWidget({
    super.key,
    required this.downloads,
    required this.title,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    if (downloads.isEmpty) {
      return EmptyStateWidget(title: title);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final download = downloads[index];
        return DownloadItemWidget(
          download: download,
          title: title,
          cubit: cubit,
        );
      },
    );
  }
}
